const std = @import("std");
const keys = @import("keys.zig");
const actions = @import("actions.zig");
const properties = @import("properties.zig");

const Mapping = @import("Mapping.zig");

gpa: std.mem.Allocator,
mappings: std.ArrayListUnmanaged([]const []const u8) = .{},
autostart: std.ArrayListUnmanaged([]const u8) = .{},
props: std.ArrayListUnmanaged([]const []const u8) = .{},

pub fn init(gpa: std.mem.Allocator) Context {
    return .{
        .gpa = gpa,
    };
}

pub fn deinit(self: *Context) void {
    self.mappings.deinit(self.gpa);
    self.autostart.deinit(self.gpa);
}

pub fn addProp(self: *Context, comptime property: properties.Property) !void {
    try self.props.append(self.gpa, property.serialize());
}

pub fn map(
    self: *Context,
    comptime mode: @TypeOf(.enum_literal),
    comptime mods: []const keys.ModKey,
    comptime key: Mapping.MappingKey,
    comptime action: actions.Action,
) !void {
    try self.addMap(.{ .mode = mode, .mod_comb = mods, .key = key, .action = action });
}

pub fn addRun(
    self: *Context,
    comptime mode: @TypeOf(.enum_literal),
    comptime mods: []const keys.ModKey,
    comptime key: Mapping.MappingKey,
    comptime cmd: @TypeOf(.enum_literal),
) !void {
    try self.addMap(.{ .mode = mode, .mod_comb = mods, .key = key, .action = .{ .spawn = cmd } });
}

pub fn addMap(self: *Context, comptime mapping: Mapping) !void {
    const s = try mapping.serialize(self.gpa);
    try self.mappings.append(self.gpa, s);
}

pub fn run(self: *Context, comptime cmd: @TypeOf(.enum_literal)) !void {
    const argv: []const []const u8 = &.{ "riverctl", @tagName(cmd) };
    const p = try std.process.Child.run(.{ .allocator = self.gpa, .argv = argv });
    self.gpa.free(p.stdout);
    self.gpa.free(p.stderr);
}

pub fn addAutostart(self: *Context, comptime shell_command: @TypeOf(.enum_literal)) !void {
    try self.autostart.append(self.gpa, @tagName(shell_command));
}

pub fn dump(self: *Context) !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.writeAll("\nmappings:\n");
    for (self.mappings.items, 0..) |m, i| {
        try stdout.print("{d}: {s}\n", .{ i, m });
    }

    try stdout.writeAll("\nautostart:\n");
    for (self.autostart.items, 0..) |a, i| {
        try stdout.print("{d}: {s}\n", .{ i, a });
    }

    try stdout.writeAll("\nproperties:\n");
    for (self.props.items, 0..) |p, i| {
        try stdout.print("{d}: {s}\n", .{ i, p });
    }
}

pub fn apply(self: *Context) !void {
    var timer = try std.time.Timer.start();
    const stdout = std.io.getStdOut().writer();

    try stdout.writeAll("\x1B[0;36m 󰒓  Spawning autostart applications...\x1B[0m\n");
    try self.applyAutostart();

    try stdout.writeAll("\x1B[0;36m 󰒓  Configuring key bindings...\x1B[0m\n");
    try self.applyMappings();

    try stdout.writeAll("\x1B[0;36m 󰒓  Applying general properties...\x1B[0m\n");
    try self.applyProperties();

    try stdout.writeAll("\x1B[0;32m   Configuration complete\x1B[0m\n");
    try self.notifyNormal("  Configuration complete ({d}ms)", .{
        @divExact(@as(f64, @floatFromInt(timer.lap())), @as(f64, @floatFromInt(std.time.ns_per_ms))),
    });
}

pub fn applyProperties(self: *Context) !void {
    for (self.props.items) |i| {
        var argv_buf = std.ArrayList([]const u8).init(self.gpa);
        try argv_buf.append("riverctl");

        for (i) |j| {
            try argv_buf.append(j);
        }

        const p = try std.process.Child.run(.{ .allocator = self.gpa, .argv = argv_buf.items });
        self.gpa.free(p.stdout);
        self.gpa.free(p.stderr);
        argv_buf.deinit();
    }
}

pub fn applyAutostart(self: *Context) !void {
    for (self.autostart.items) |i| {
        const kill_argv: []const []const u8 = &.{ "killall", "-q", i[0 .. std.mem.indexOfScalar(u8, i, ' ') orelse i.len] };
        const kill_p = try std.process.Child.run(.{ .argv = kill_argv, .allocator = self.gpa });
        self.gpa.free(kill_p.stdout);
        self.gpa.free(kill_p.stderr);

        const argv: []const []const u8 = &.{ "riverctl", "spawn", i };
        const p = try std.process.Child.run(.{ .argv = argv, .allocator = self.gpa });
        self.gpa.free(p.stdout);
        self.gpa.free(p.stderr);
    }
}

pub fn applyMappings(self: *Context) !void {
    for (self.mappings.items) |i| {
        var argv_buf = std.ArrayList([]const u8).init(self.gpa);
        try argv_buf.append("riverctl");
        try argv_buf.append("map");

        for (i) |j| {
            try argv_buf.append(j);
        }

        const p = try std.process.Child.run(.{ .argv = argv_buf.items, .allocator = self.gpa });
        self.gpa.free(p.stdout);
        self.gpa.free(p.stderr);
        argv_buf.deinit();
    }
}

pub fn notifyLow(self: *Context, comptime fmt: []const u8, args: anytype) !void {
    try self.notify("low", fmt, args);
}

pub fn notifyNormal(self: *Context, comptime fmt: []const u8, args: anytype) !void {
    try self.notify("normal", fmt, args);
}

pub fn notifyCrit(self: *Context, comptime fmt: []const u8, args: anytype) !void {
    try self.notifyCrit("critical", fmt, args);
}

pub fn notify(self: *Context, comptime urgency: []const u8, comptime fmt: []const u8, args: anytype) !void {
    var buf: [1024]u8 = .{0} ** 1024;
    const msg = try std.fmt.bufPrint(&buf, fmt, args);
    const argv: []const []const u8 = &.{ "notify-send", "-a", "river", "-u", urgency, msg };
    const p = try std.process.Child.run(.{ .argv = argv, .allocator = self.gpa });
    self.gpa.free(p.stdout);
    self.gpa.free(p.stderr);
}

const Context = @This();
