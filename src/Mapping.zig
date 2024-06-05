const std = @import("std");
const keys = @import("keys.zig");
const actions = @import("actions.zig");

pub const MappingKey = union(enum) {
    normal: keys.Key,
    mouse: keys.MouseButton,
    custom: []const u8,
};

mode: @TypeOf(.enum_literal),
mod_comb: []const keys.ModKey,
key: MappingKey,
action: actions.Action,

pub fn init(mod_comb: []const keys.ModKey, key: MappingKey) Mapping {
    return .{
        .mod_comb = mod_comb,
        .key = key,
    };
}

/// Constructs a string containing a mapping decl for riverctl.
/// Caller owns the memory.
pub fn serialize(self: *const Mapping, gpa: std.mem.Allocator) ![]const []const u8 {
    var buf = std.ArrayList([]const u8).init(gpa);

    try buf.append(@tagName(self.mode));

    var comb_buf = std.ArrayList(u8).init(gpa);
    for (self.mod_comb, 0..) |k, i| {
        try comb_buf.writer().writeAll(k.asSlice());
        if (i + 1 == self.mod_comb.len) break;
        try comb_buf.writer().writeByte('+');
    }
    try buf.append(try comb_buf.toOwnedSlice());

    try buf.append(switch (self.key) {
        .normal => |k| comptime k.asSlice(),
        .custom => |k| k,
        .mouse => |k| comptime k.asSlice(),
    });
    try buf.appendSlice(self.action.serialize());

    return try buf.toOwnedSlice();
}

const Mapping = @This();
