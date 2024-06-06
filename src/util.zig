const a = @import("actions.zig");

pub const action_fns = struct {
    pub fn focusOutput(name: ?@TypeOf(.enum_literal), dir: ?a.FocusDirection) a.Action {
        if (name) |n| return .{ .@"focus-output" = .{ .name = n } };
        if (dir) |d| return .{ .@"focus-output" = .{ .direction = d } };
        @compileError("You must provide at least 1 argument");
    }

    pub fn focusView(comptime skip_floating: bool, name: ?@TypeOf(.enum_literal), dir: ?a.FocusDirection) a.Action {
        if (name) |n| return .{ .@"focus-view" = .{ .skip_floating = skip_floating, .arg = .{ .name = n } } };
        if (dir) |d| return .{ .@"focus-view" = .{ .skip_floating = skip_floating, .arg = .{ .direction = d } } };
        @compileError("You must provide at least 1 argument");
    }

    pub fn swap(comptime dir: a.FocusDirection) a.Action {
        return .{ .swap = dir };
    }

    pub fn sendToOutput(comptime current_tags: bool, name: ?@TypeOf(.enum_literal), dir: ?a.FocusDirection) a.Action {
        if (name) |n| return .{ .@"send-to-output" = .{ .current_tags = current_tags, .arg = .{ .name = n } } };
        if (dir) |d| return .{ .@"send-to-output" = .{ .current_tags = current_tags, .arg = .{ .direction = d } } };
        @compileError("You must provide at least 1 argument");
    }

    pub fn sendLayoutCmd(namespace: @TypeOf(.enum_literal), cmd: @TypeOf(.enum_literal)) a.Action {
        return .{ .@"send-layout-cmd" = .{ .namespace = namespace, .cmd = cmd } };
    }

    pub fn move(comptime delta: usize, comptime dir: a.Direction) a.Action {
        return .{ .move = .{ .delta = delta, .direction = dir } };
    }

    pub fn setFocusedTags(comptime tags: u32) a.Action {
        return .{ .@"set-focused-tags" = tags };
    }

    pub fn setViewTags(comptime tags: u32) a.Action {
        return .{ .@"set-view-tags" = tags };
    }

    pub fn toggleFocusedTags(comptime tags: u32) a.Action {
        return .{ .@"set-view-tags" = tags };
    }

    pub fn toggleViewTags(comptime tags: u32) a.Action {
        return .{ .@"toggle-view-tags" = tags };
    }

    pub fn spawnTagmask(comptime mask: u32) a.Action {
        return .{ .@"spawn-tagmask" = mask };
    }

    pub fn spawn(comptime cmd: []const u8) a.Action {
        return .{ .spawn = cmd };
    }

    pub fn enterMode(comptime name: @TypeOf(.enum_literal)) a.Action {
        return .{ .@"enter-mode" = name };
    }

    // Functions for consistency
    pub fn close() a.Action {
        return .close;
    }

    pub fn exit() a.Action {
        return .exit;
    }

    pub fn toggleFloat() a.Action {
        return .@"toggle-float";
    }

    pub fn toggleFullscreen() a.Action {
        return .@"toggle-fullscreen";
    }

    pub fn moveView() a.Action {
        return .@"move-view";
    }

    pub fn resizeView() a.Action {
        return .@"resize-view";
    }
};
