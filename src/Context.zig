const std = @import("std");
const keys = @import("keys.zig");
const actions = @import("actions.zig");
const properties = @import("properties.zig");

const Mapping = @import("Mapping.zig");

gpa: std.mem.Allocator,

autostarts: std.ArrayListUnmanaged([]const u8) = .{},
modes: std.ArrayListUnmanaged([]const u8) = .{},
mappings: std.ArrayListUnmanaged([]const []const u8) = .{},
mouse_mappings: std.ArrayListUnmanaged([]const []const u8) = .{},
props: std.ArrayListUnmanaged([]const []const u8) = .{},

pub fn init(gpa: std.mem.Allocator) Context {
    return .{
        .gpa = gpa,
    };
}

pub fn deinit(self: *Context) void {
    self.modes.deinit(self.gpa);
    self.mouse_mappings.deinit(self.gpa);
    self.mappings.deinit(self.gpa);
    self.autostarts.deinit(self.gpa);
    self.props.deinit(self.gpa);
}

pub fn declareMode(self: *Context, comptime name: @TypeOf(.enum_literal)) !void {
    try self.modes.append(self.gpa, @tagName(name));
}

pub fn Mapper(comptime mode: @TypeOf(.enum_literal)) type {
    return struct {
        const _mode = mode;

        ctx: *Context = undefined,

        pub fn init(ctx: *Context) @This() {
            return .{ .ctx = ctx };
        }

        pub fn custom(m: *const @This(), comptime k: []const u8, comptime a: actions.Action) !void {
            try m.ctx.mapCustom(_mode, &.{.none}, k, a);
        }

        pub fn customMod(m: *const @This(), comptime mod: keys.ModKey, comptime k: []const u8, comptime a: actions.Action) !void {
            try m.ctx.mapCustom(_mode, &.{mod}, k, a);
        }

        pub fn customMods(m: *const @This(), comptime mods: []const keys.ModKey, comptime k: []const u8, comptime a: actions.Action) !void {
            try m.ctx.mapCustom(_mode, mods, k, a);
        }

        pub fn key(m: *const @This(), comptime k: keys.Key, comptime a: actions.Action) !void {
            try m.ctx.mapKey(_mode, &.{.none}, k, a);
        }

        pub fn keyMod(m: *const @This(), comptime mod: keys.ModKey, comptime k: keys.Key, comptime a: actions.Action) !void {
            try m.ctx.mapKey(_mode, &.{mod}, k, a);
        }

        pub fn keyMods(m: *const @This(), comptime mods: []const keys.ModKey, comptime k: keys.Key, comptime a: actions.Action) !void {
            try m.ctx.mapKey(_mode, mods, k, a);
        }

        pub fn ptr(m: *const @This(), comptime b: keys.MouseButton, comptime a: actions.Action) !void {
            try m.ctx.mapPtr(_mode, &.{.none}, b, a);
        }

        pub fn ptrMod(m: *const @This(), comptime mod: keys.ModKey, comptime b: keys.MouseButton, comptime a: actions.Action) !void {
            try m.ctx.mapPtr(_mode, &.{mod}, b, a);
        }

        pub fn ptrMods(m: *const @This(), comptime mods: []const keys.ModKey, comptime b: keys.MouseButton, comptime a: actions.Action) !void {
            try m.ctx.mapPtr(_mode, mods, b, a);
        }
    };
}

pub fn property(self: *Context, comptime prop: properties.Property) !void {
    try self.props.append(self.gpa, prop.serialize());
}

pub fn map(self: *Context, comptime to: enum { key, ptr, custom }, comptime mapping: Mapping) !void {
    switch (to) {
        .key, .custom => try self.mappings.append(self.gpa, try mapping.serialize(self.gpa)),
        .ptr => try self.mouse_mappings.append(self.gpa, try mapping.serialize(self.gpa)),
    }
}

pub fn mapKey(
    self: *Context,
    comptime mode: @TypeOf(.enum_literal),
    comptime mods: []const keys.ModKey,
    comptime key: keys.Key,
    comptime act: actions.Action,
) !void {
    try self.map(.key, .{ .mode = mode, .mod_comb = mods, .key = .{ .normal = key }, .action = act });
}

pub fn mapPtr(
    self: *Context,
    comptime mode: @TypeOf(.enum_literal),
    comptime mods: []const keys.ModKey,
    comptime button: keys.MouseButton,
    comptime act: actions.Action,
) !void {
    try self.map(.ptr, .{ .mode = mode, .mod_comb = mods, .key = .{ .mouse = button }, .action = act });
}

pub fn mapCustom(
    self: *Context,
    comptime mode: @TypeOf(.enum_literal),
    comptime mods: []const keys.ModKey,
    comptime key: []const u8,
    act: actions.Action,
) !void {
    try self.map(.custom, .{ .mode = mode, .mod_comb = mods, .key = .{ .custom = key }, .action = act });
}

pub fn autostart(self: *Context, comptime shell_command: []const u8) !void {
    try self.autostarts.append(self.gpa, shell_command);
}

pub fn finish(self: *Context) !void {
    for (self.modes.items) |m| try self.declMode(m);
    for (self.autostarts.items) |cmd| try self.setAutostart(cmd);
    for (self.mappings.items) |m| try self.setMapping(false, m);
    for (self.mouse_mappings.items) |mm| try self.setMapping(true, mm);
    for (self.props.items) |prop| try self.setProperty(prop);

    try self.notify(.normal, "  Configuration complete", .{});
}

pub fn dump(self: *Context) !void {
    var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
    const w = bw.writer();

    try w.writeAll(try self.colorize(red, " Configuration Dump \n", .{}));
    try w.writeAll(try self.colorize(cyan, " Declared Modes: {d} total \n", .{self.modes.items.len}));
    for (self.modes.items) |i| try w.print("{s}: {s}\n", .{ try self.colorize(red, "   mode", .{}), try self.colorize(green, "{s}", .{i}) });

    try w.writeAll(try self.colorize(cyan, "\n Configured Properties: {d} total \n", .{self.props.items.len}));
    for (self.props.items) |i| try w.print("{s}: {s}\n", .{ try self.colorize(red, " 󱍰  property", .{}), try self.colorize(green, "{s}", .{i}) });

    try w.writeAll(try self.colorize(cyan, "\n Autostart Commands: {d} total \n", .{self.autostarts.items.len}));
    for (self.autostarts.items) |i| try w.print("{s}: {s}\n", .{ try self.colorize(red, "  autostart", .{}), try self.colorize(green, "{s}", .{i}) });

    try w.writeAll(try self.colorize(cyan, "\n Mouse Mappings: {d} total \n", .{self.mouse_mappings.items.len}));
    for (self.mouse_mappings.items) |i| try w.print("{s}: {s}\n", .{ try self.colorize(red, " 󰍽 mouse", .{}), try self.colorize(green, "{s}", .{i}) });

    try w.writeAll(try self.colorize(cyan, "\n Keyboard Mappings: {d} total\n", .{self.mappings.items.len}));
    for (self.mappings.items) |i| try w.print("{s}: {s}\n", .{ try self.colorize(red, " 󰌌 keyboard", .{}), try self.colorize(green, "{s}", .{i}) });
    try w.writeByte('\n');
    try bw.flush();
}

fn declMode(self: *Context, mode: []const u8) !void {
    try self.oneshot(&.{ "riverctl", "declare-mode", mode });
}

fn setMapping(self: *Context, comptime is_mouse: bool, mapping: []const []const u8) !void {
    var argv = std.ArrayList([]const u8).init(self.gpa);
    defer argv.deinit();

    try argv.appendSlice(&.{ "riverctl", if (is_mouse) "map-pointer" else "map" });
    for (mapping) |entry| try argv.append(entry);
    try self.oneshot(argv.items);
}

fn setProperty(self: *Context, prop: []const []const u8) !void {
    var argv = std.ArrayList([]const u8).init(self.gpa);
    defer argv.deinit();

    try argv.append("riverctl");
    for (prop) |entry| try argv.append(entry);
    try self.oneshot(argv.items);
}

fn setAutostart(self: *Context, cmd: []const u8) !void {
    try self.oneshot(&.{ "killall", "-q", cmd[0 .. std.mem.indexOfScalar(u8, cmd, ' ') orelse cmd.len] });
    try self.oneshot(&.{ "riverctl", "spawn", cmd });
}

fn notify(self: *Context, comptime urgency: @TypeOf(.enum_literal), comptime fmt: []const u8, args: anytype) !void {
    const msg = std.fmt.comptimePrint(fmt, args);
    const argv: []const []const u8 = &.{ "notify-send", "-a", "river", "-u", @tagName(urgency), msg };
    try self.oneshot(argv);
}

fn oneshot(self: *Context, argv: []const []const u8) !void {
    const p = try std.process.Child.run(.{ .allocator = self.gpa, .argv = argv });
    self.gpa.free(p.stdout);
    self.gpa.free(p.stderr);
}

fn colorize(self: *Context, comptime color: []const u8, comptime fmt: []const u8, args: anytype) ![]const u8 {
    var buf: [1024]u8 = undefined;
    const msg = try std.fmt.bufPrint(&buf, fmt, args);
    return try std.fmt.allocPrint(self.gpa, "{s}{s}{s}", .{ color, msg, reset });
}

const Context = @This();
const cyan = "\x1B[0;36m";
const green = "\x1B[0;32m";
const red = "\x1B[0;31m";
const reset = "\x1B[0;0m";
