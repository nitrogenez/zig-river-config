const std = @import("std");
const rconf = @import("root.zig");
const act = @import("util.zig").action_fns;

const NormalMapper = rconf.Context.Mapper(.normal);
const PowerMapper = rconf.Context.Mapper(.power);
const PassthroughMapper = rconf.Context.Mapper(.passthrough);
const LockedMapper = rconf.Context.Mapper(.locked);

pub const aliases = struct {
    pub const terminal = "alacritty";
    pub const topbar = "waybar";
    pub const notif_daemon = "mako";
    pub const wallpaper_path = "~/.wallpaper";
    pub const background = "swaybg -i";
    pub const launcher = "wofi";
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var ctx = rconf.Context.init(arena.allocator());
    defer arena.deinit();
    defer ctx.deinit();

    var dump = false;
    var args = std.process.args();
    _ = args.skip();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--dump")) {
            dump = true;
            break;
        }
    }

    const n = NormalMapper.init(&ctx);
    const p = PowerMapper.init(&ctx);
    const pt = PassthroughMapper.init(&ctx);

    try ctx.autostart(aliases.notif_daemon);
    try ctx.autostart(aliases.topbar);
    try ctx.autostart(std.fmt.comptimePrint("{s} {s}", .{ aliases.background, aliases.wallpaper_path }));
    try ctx.autostart("rivertile -view-padding 6 -outer-padding 6");

    try ctx.property(.{ .@"set-repeat" = .{ .rate = 50, .delay = 300 } });
    try ctx.property(.{ .@"background-color" = 0x11111b });
    try ctx.property(.{ .@"border-color-focused" = 0x74c7ec });
    try ctx.property(.{ .@"border-color-unfocused" = 0x181825 });
    try ctx.property(.{ .@"border-color-urgent" = 0xf5e0dc });
    try ctx.property(.{ .@"default-layout" = .rivertile });

    // Essential mappings: Reload & terminal
    try n.keyMod(.super, .r, .{ .spawn = "$HOME/.config/river/init" });
    try n.keyMod(.super, .@"return", .{ .spawn = aliases.terminal });
    try n.keyMod(.super, .d, .{ .spawn = aliases.launcher });

    // Compositor controls
    try n.keyMod(.super, .q, .close);
    try n.keyMods(&.{ .super, .shift }, .e, .exit);

    // Output/view controls
    try n.keyMod(.super, .j, act.focusView(false, null, .next));
    try n.keyMod(.super, .k, act.focusView(false, null, .previous));
    try n.keyMod(.super, .period, act.focusOutput(null, .next));
    try n.keyMod(.super, .comma, act.focusOutput(null, .previous));
    try n.keyMods(&.{ .super, .shift }, .j, act.swap(.next));
    try n.keyMods(&.{ .super, .shift }, .k, act.swap(.previous));
    try n.keyMods(&.{ .super, .shift }, .period, act.sendToOutput(false, null, .next));
    try n.keyMods(&.{ .super, .shift }, .comma, act.sendToOutput(false, null, .previous));
    try n.keyMods(&.{ .super, .shift }, .@"return", .zoom);

    // Rivertile configuration
    try n.keyMod(.super, .up, act.sendLayoutCmd(.rivertile, .@"main-location top"));
    try n.keyMod(.super, .down, act.sendLayoutCmd(.rivertile, .@"main-location bottom"));
    try n.keyMod(.super, .left, act.sendLayoutCmd(.rivertile, .@"main-location left"));
    try n.keyMod(.super, .right, act.sendLayoutCmd(.rivertile, .@"main-location right"));
    try n.keyMod(.super, .h, act.sendLayoutCmd(.rivertile, .@"main-ratio -0.05"));
    try n.keyMod(.super, .l, act.sendLayoutCmd(.rivertile, .@"main-ratio +0.05"));
    try n.keyMods(&.{ .super, .shift }, .h, act.sendLayoutCmd(.rivertile, .@"main-count +1"));
    try n.keyMods(&.{ .super, .shift }, .l, act.sendLayoutCmd(.rivertile, .@"main-count -1"));

    // Client controls
    try n.keyMods(&.{ .super, .alt }, .h, act.move(100, .left));
    try n.keyMods(&.{ .super, .alt }, .l, act.move(100, .right));
    try n.keyMods(&.{ .super, .alt }, .j, act.move(100, .down));
    try n.keyMods(&.{ .super, .alt }, .k, act.move(100, .up));
    try n.keyMod(.super, .v, act.toggleFloat());
    try n.keyMod(.super, .f, act.toggleFullscreen());
    try n.ptrMod(.super, .left, act.moveView());
    try n.ptrMod(.super, .right, act.resizeView());
    try n.ptrMod(.super, .middle, act.toggleFloat());

    // Tag (workspace) navigation
    inline for (1..10) |tag| {
        const tags: u32 = (1 << (tag - 1));
        const key = comptime rconf.keys.Key.getNumber(tag) orelse .@"0";

        try n.keyMod(.super, key, act.setFocusedTags(tags));
        try n.keyMods(&.{ .super, .shift }, key, act.setViewTags(tags));
        try n.keyMods(&.{ .super, .control }, key, act.toggleFocusedTags(tags));
        try n.keyMods(&.{ .super, .control }, key, act.toggleViewTags(tags));
    }

    {
        const all_tags: u32 = ((1 << 32) - 1);
        try n.keyMod(.super, .@"0", act.setFocusedTags(all_tags));
        try n.keyMods(&.{ .super, .shift }, .@"0", act.setViewTags(all_tags));
    }

    inline for (.{ .normal, .locked, .power }) |mode| {
        try ctx.mapCustom(mode, &.{.none}, "XF86AudioRaiseVolume", act.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"));
        try ctx.mapCustom(mode, &.{.none}, "XF86AudioLowerVolume", act.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"));
        try ctx.mapCustom(mode, &.{.none}, "XF86AudioMute", act.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"));
        try ctx.mapCustom(mode, &.{.none}, "XF86MonBrightnessUp", act.spawn("brightnessctl set +5%"));
        try ctx.mapCustom(mode, &.{.none}, "XF86MonBrightnessDown", act.spawn("brightnessctl set -5%"));
    }

    try ctx.declareMode(.power);
    try n.keyMod(.super, .p, act.enterMode(.power));
    {
        try p.key(.escape, act.enterMode(.normal));
        try p.key(.@"return", act.enterMode(.normal));
        try p.key(.p, act.spawn("poweroff"));
        try p.key(.r, act.spawn("reboot"));
        try p.key(.e, act.exit());
    }

    try ctx.declareMode(.passthrough);
    try n.keyMod(.super, .f11, act.enterMode(.passthrough));
    {
        try pt.keyMod(.super, .f11, act.enterMode(.normal));
    }
    try ctx.finish();

    if (dump) try ctx.dump();
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
