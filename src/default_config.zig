const std = @import("std");
const rconf = @import("root.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var ctx = rconf.Context.init(arena.allocator());
    defer ctx.deinit();

    try ctx.addAutostart(.mako);
    try ctx.addAutostart(.waybar);
    try ctx.addAutostart(.@"swaybg -i $HOME/.wallpaper");
    try ctx.addAutostart(.@"rivertile -view-padding 6 -outer-padding 6");

    try ctx.addProp(.{ .@"set-repeat" = .{ .rate = 50, .delay = 300 } });
    try ctx.addProp(.{ .@"background-color" = 0x11111b });
    try ctx.addProp(.{ .@"border-color-focused" = 0x74c7ec });
    try ctx.addProp(.{ .@"border-color-unfocused" = 0x181825 });
    try ctx.addProp(.{ .@"border-color-urgent" = 0xf5e0dc });
    try ctx.addProp(.{ .@"default-layout" = .rivertile });

    try ctx.map(.normal, &.{.super}, .{ .normal = .r }, .{ .spawn = .@"$HOME/.config/river/init" });
    try ctx.map(.normal, &.{.super}, .{ .normal = .d }, .{ .spawn = .wofi });
    try ctx.map(.normal, &.{.super}, .{ .normal = .q }, .close);
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .e }, .exit);
    try ctx.map(.normal, &.{.super}, .{ .normal = .j }, .{ .@"focus-view" = .{ .arg = .{ .direction = .next } } });
    try ctx.map(.normal, &.{.super}, .{ .normal = .k }, .{ .@"focus-view" = .{ .arg = .{ .direction = .previous } } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .j }, .{ .swap = .next });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .k }, .{ .swap = .previous });
    try ctx.map(.normal, &.{.super}, .{ .normal = .period }, .{ .@"focus-output" = .{ .direction = .next } });
    try ctx.map(.normal, &.{.super}, .{ .normal = .comma }, .{ .@"focus-output" = .{ .direction = .previous } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .period }, .{ .@"send-to-output" = .{ .arg = .{ .direction = .next } } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .comma }, .{ .@"send-to-output" = .{ .arg = .{ .direction = .previous } } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .@"return" }, .zoom);
    try ctx.map(.normal, &.{.super}, .{ .normal = .h }, .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-ratio -0.05" } });
    try ctx.map(.normal, &.{.super}, .{ .normal = .l }, .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-ratio +0.05" } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .h }, .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-count +1" } });
    try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .l }, .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-count -1" } });

    try ctx.map(.normal, &.{ .super, .alt }, .{ .normal = .h }, .{ .move = .{ .delta = 100, .direction = .left } });
    try ctx.map(.normal, &.{ .super, .alt }, .{ .normal = .l }, .{ .move = .{ .delta = 100, .direction = .right } });
    try ctx.map(.normal, &.{ .super, .alt }, .{ .normal = .j }, .{ .move = .{ .delta = 100, .direction = .down } });
    try ctx.map(.normal, &.{ .super, .alt }, .{ .normal = .k }, .{ .move = .{ .delta = 100, .direction = .up } });

    inline for (1..10) |tag| {
        const tags = (1 << (tag - 1));
        const k = comptime rconf.keys.Key.getNumber(tag) orelse unreachable;

        try ctx.map(.normal, &.{.super}, .{ .normal = k }, .{ .@"set-focused-tags" = tags });
        try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = k }, .{ .@"set-view-tags" = tags });
        try ctx.map(.normal, &.{ .super, .control }, .{ .normal = k }, .{ .@"toggle-focused-tags" = tags });
        try ctx.map(.normal, &.{ .super, .control }, .{ .normal = k }, .{ .@"toggle-view-tags" = tags });
    }
    {
        const all_tags: usize = ((1 << 32) - 1);
        try ctx.map(.normal, &.{.super}, .{ .normal = .@"0" }, .{ .@"set-focused-tags" = all_tags });
        try ctx.map(.normal, &.{ .super, .shift }, .{ .normal = .@"0" }, .{ .@"set-view-tags" = all_tags });
    }

    try ctx.map(.normal, &.{.super}, .{ .normal = .space }, .@"toggle-float");
    try ctx.map(.normal, &.{.super}, .{ .normal = .f }, .@"toggle-fullscreen");

    try ctx.map(
        .normal,
        &.{.super},
        .{ .normal = .up },
        .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-location top" } },
    );
    try ctx.map(
        .normal,
        &.{.super},
        .{ .normal = .right },
        .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-location right" } },
    );
    try ctx.map(
        .normal,
        &.{.super},
        .{ .normal = .down },
        .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-location bottom" } },
    );
    try ctx.map(
        .normal,
        &.{.super},
        .{ .normal = .left },
        .{ .@"send-layout-cmd" = .{ .namespace = .rivertile, .cmd = .@"main-location left" } },
    );

    inline for (.{ .normal, .locked }) |mode| {
        try ctx.map(mode, &.{.none}, .{ .custom = "XF86AudioRaiseVolume" }, .{ .spawn = .@"pactl set-sink-volume @DEFAULT_SINK@ +5%" });
        try ctx.map(mode, &.{.none}, .{ .custom = "XF86AudioLowerVolume" }, .{ .spawn = .@"pactl set-sink-volume @DEFAULT_SINK@ -5%" });
        try ctx.map(mode, &.{.none}, .{ .custom = "XF86AudioMute" }, .{ .spawn = .@"pactl set-sink-mute @DEFAULT_SINK@ toggle" });
        try ctx.map(mode, &.{.none}, .{ .custom = "XF86MonBrightnessUp" }, .{ .spawn = .@"brightnessctl set +5%" });
        try ctx.map(mode, &.{.none}, .{ .custom = "XF86MonBrightnessDown" }, .{ .spawn = .@"brightnessctl set -5%" });
    }

    if (appExists("alacritty")) {
        try ctx.addRun(.normal, &.{.super}, .{ .normal = .@"return" }, .alacritty);
    } else if (appExists("foot")) {
        try ctx.addRun(.normal, &.{.super}, .{ .normal = .@"return" }, .foot);
    } else if (appExists("gnome-terminal")) {
        try ctx.addRun(.normal, &.{.super}, .{ .normal = .@"return" }, .@"gnome-terminal");
    } else if (appExists("kitty")) {
        try ctx.addRun(.normal, &.{.super}, .{ .normal = .@"return" }, .kitty);
    }

    try ctx.apply();
}

fn appExists(comptime name: []const u8) bool {
    const path_env = std.posix.getenv("PATH") orelse return false;
    var path_it = std.mem.splitScalar(u8, path_env, ':');
    var found: bool = false;

    while (path_it.next()) |p| {
        const app_path = std.fs.path.join(std.heap.page_allocator, &.{ p, name }) catch @panic("OOM");
        const f = std.fs.openFileAbsolute(app_path, .{}) catch {
            std.heap.page_allocator.free(app_path);
            continue;
        };
        f.close();
        found = true;
        break;
    }
    return found;
}
