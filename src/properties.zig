const std = @import("std");

pub const AttachModeTag = enum {
    top,
    bottom,
    above,
    below,
    after,
};

pub const AttachMode = struct {
    tag: AttachModeTag,
    n: ?usize = null,
};

pub const Property = union(enum) {
    @"default-attach-mode": AttachMode,
    @"output-attach-mode": AttachMode,
    @"background-color": u32,
    @"border-color-focused": u32,
    @"border-color-unfocused": u32,
    @"border-color-urgent": u32,
    @"border-width": usize,
    @"focus-follows-cursor": enum { disabled, normal, always },
    @"hide-cursor": union(enum) { timeout: usize, @"when-typing": enum { enabled, disabled } },
    @"set-cursor-warp": enum { disabled, @"on-output-change", @"on-focus-change" },
    @"set-repeat": struct { rate: usize, delay: usize },
    @"xcursor-theme": struct { name: @TypeOf(.enum_literal), size: ?usize = null },
    @"default-layout": @TypeOf(.enum_literal),

    pub fn serialize(comptime self: Property) []const []const u8 {
        return switch (self) {
            .@"background-color",
            .@"border-color-focused",
            .@"border-color-unfocused",
            .@"border-color-urgent",
            => |value| &.{ @tagName(self), std.fmt.comptimePrint("0x{X}", .{value}) },
            .@"border-width" => |value| &.{ @tagName(self), std.fmt.comptimePrint("{d}", .{value}) },
            .@"default-attach-mode",
            .@"output-attach-mode",
            => |i| &.{ @tagName(self), @tagName(i.tag), if (i.n) |n| std.fmt.comptimePrint("{d}", .{n}) else "" },
            .@"focus-follows-cursor" => |i| &.{ @tagName(self), @tagName(i) },
            .@"hide-cursor" => |i| &.{@tagName(self)} ++ switch (i) {
                .timeout => |j| &.{std.fmt.comptimePrint("{d}", .{j})},
                .@"when-typing" => |j| &.{ @tagName(i), @tagName(j) },
            },
            .@"set-cursor-warp" => |i| &.{ @tagName(self), @tagName(i) },
            .@"set-repeat" => |i| &.{ @tagName(self), std.fmt.comptimePrint("{d}", .{i.rate}), std.fmt.comptimePrint("{d}", .{i.delay}) },
            .@"xcursor-theme",
            => |i| &.{ @tagName(self), @tagName(i.name), if (i.size) |s| std.fmt.comptimePrint("{d}", .{s}) else "" },
            .@"default-layout" => |i| &.{ @tagName(self), @tagName(i) },
        };
    }
};
