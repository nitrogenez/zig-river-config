const std = @import("std");

pub const FocusDirection = enum {
    next,
    previous,
    up,
    down,
    left,
    right,
};

pub const Direction = enum {
    up,
    down,
    left,
    right,
};

pub const Orientation = enum {
    horizontal,
    vertical,
};

pub const FocusOutputArg = union(enum) {
    name: @TypeOf(.enum_literal),
    direction: FocusDirection,

    pub fn asSlice(self: FocusOutputArg) []const u8 {
        return switch (self) {
            .name => |n| @tagName(n),
            .direction => |d| @tagName(d),
        };
    }
};

pub const Action = union(enum) {
    close,
    exit,
    @"focus-output": FocusOutputArg,
    @"focus-view": struct {
        skip_floating: bool = false,
        arg: FocusOutputArg,
    },
    move: struct {
        delta: usize,
        direction: Direction,
    },
    resize: struct {
        delta: usize,
        orientation: Orientation,
    },
    snap: Direction,
    @"send-to-output": struct {
        current_tags: bool = false,
        arg: FocusOutputArg,
    },
    spawn: @TypeOf(.enum_literal),
    swap: FocusDirection,
    @"toggle-float",
    @"toggle-fullscreen",
    zoom,
    @"default-layout": @TypeOf(.enum_literal),
    @"output-layout": @TypeOf(.enum_literal),
    @"send-layout-cmd": struct {
        namespace: @TypeOf(.enum_literal),
        cmd: @TypeOf(.enum_literal),
    },
    @"set-focused-tags": u32,
    @"set-view-tags": u32,
    @"toggle-focused-tags": u32,
    @"toggle-view-tags": u32,
    @"spawn-tagmask": u32,
    @"focus-previous-tags",
    @"send-to-previous-tags",
    @"move-view",
    @"resize-view",

    pub fn serialize(comptime self: Action) []const []const u8 {
        return switch (self) {
            .close,
            .exit,
            .@"toggle-float",
            .@"toggle-fullscreen",
            .zoom,
            .@"focus-previous-tags",
            .@"send-to-previous-tags",
            .@"move-view",
            .@"resize-view",
            => &.{@tagName(self)},
            .@"focus-output" => |i| &.{ @tagName(self), comptime i.asSlice() },
            .@"focus-view" => |i| &.{ @tagName(self), if (i.skip_floating) "-skip-floating" else "", comptime i.arg.asSlice() },
            .@"default-layout",
            .@"output-layout",
            .spawn,
            => |i| &.{ @tagName(self), @tagName(i) },
            .@"send-layout-cmd" => |i| &.{ @tagName(self), @tagName(i.namespace), @tagName(i.cmd) },
            .@"set-focused-tags",
            .@"set-view-tags",
            .@"toggle-focused-tags",
            .@"toggle-view-tags",
            .@"spawn-tagmask",
            => |i| &.{ @tagName(self), std.fmt.comptimePrint("{d}", .{i}) },
            .move => |i| &.{ @tagName(self), @tagName(i.direction), std.fmt.comptimePrint("{d}", .{i.delta}) },
            .resize => |i| &.{ @tagName(self), @tagName(i.orientation), std.fmt.comptimePrint("{d}", .{i.delta}) },
            .snap => |i| &.{ @tagName(self), @tagName(i) },
            .@"send-to-output" => |i| &.{ @tagName(self), if (i.current_tags) "-current-tags" else "", comptime i.arg.asSlice() },
            .swap => |i| &.{ @tagName(self), @tagName(i) },
        };
    }
};
