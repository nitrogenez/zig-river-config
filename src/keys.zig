pub const MouseButton = enum {
    left,
    right,
    middle,
    side,
    extra,
    forward,
    back,
    task,

    pub fn asSlice(self: MouseButton) []const u8 {
        return switch (self) {
            .left => "BTN_LEFT",
            .right => "BTN_RIGHT",
            .middle => "BTN_MIDDLE",
            .side => "BTN_SIDE",
            .extra => "BTN_EXTRA",
            .forward => "BTN_FORWARD",
            .back => "BTN_BACK",
            .task => "BTN_TASK",
        };
    }
};

pub const ModKey = enum {
    mod1,
    mod2,
    mod3,
    mod4,
    mod5,
    shift,
    alt,
    control,
    none,
    caps_lock,
    shift_lock,
    super,

    pub fn asSlice(self: ModKey) []const u8 {
        return switch (self) {
            .mod1 => "Mod1",
            .mod2 => "Mod2",
            .mod3 => "Mod3",
            .mod4 => "Mod4",
            .mod5 => "Mod5",
            .shift => "Shift",
            .alt => "Alt",
            .control => "Control",
            .caps_lock => "Caps_Lock",
            .shift_lock => "Shift_Lock",
            .none => "None",
            .super => "Super",
        };
    }
};

pub const Key = enum {
    @"0",
    @"1",
    @"2",
    @"3",
    @"4",
    @"5",
    @"6",
    @"7",
    @"8",
    @"9",
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,
    @"return",
    comma,
    period,
    up,
    left,
    right,
    down,
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    l1,
    f12,
    l2,
    f13,
    l3,
    f14,
    l4,
    f15,
    l5,
    f16,
    l6,
    f17,
    l7,
    f18,
    l8,
    f19,
    l9,
    f20,
    l10,
    f21,
    l11,
    f22,
    l12,
    escape,
    print,
    insert,
    delete,
    tab,
    linefeed,
    backspace,
    scroll_lock,
    sys_req,
    pause,
    home,
    space,
    prior,
    page_up,
    next,
    page_down,
    end,
    begin,
    select,
    execute,
    undo,
    redo,
    menu,
    find,
    cancel,
    help,
    @"break",
    script_switch,
    num_lock,
    kp_space,
    kp_tab,
    kp_enter,
    kp_f1,
    kp_f2,
    kp_f3,
    kp_f4,
    kp_home,
    kp_left,
    kp_up,
    kp_right,
    kp_down,
    kp_prior,
    kp_page_up,
    kp_page_down,
    kp_next,
    kp_end,
    kp_begin,
    kp_insert,
    kp_delete,
    kp_equal,
    kp_multiply,
    kp_add,
    kp_separator,
    kp_subtract,
    kp_decimal,
    kp_divide,
    kp_0,
    kp_1,
    kp_2,
    kp_3,
    kp_4,
    kp_5,
    kp_6,
    kp_7,
    kp_8,
    kp_9,

    pub fn asSlice(self: Key) []const u8 {
        return switch (self) {
            .a => "A",
            .b => "B",
            .c => "C",
            .d => "D",
            .e => "E",
            .f => "F",
            .g => "G",
            .h => "H",
            .i => "I",
            .j => "J",
            .k => "K",
            .l => "L",
            .m => "M",
            .n => "N",
            .o => "O",
            .p => "P",
            .q => "Q",
            .r => "R",
            .s => "S",
            .t => "T",
            .u => "U",
            .v => "V",
            .w => "W",
            .x => "X",
            .y => "Y",
            .z => "Z",
            .@"return" => "Return",
            .comma => "Comma",
            .period => "Period",
            .up => "Up",
            .left => "Left",
            .right => "Right",
            .down => "Down",
            .space => "Space",
            .f1 => "F1",
            .f2 => "F2",
            .f3 => "F3",
            .f4 => "F4",
            .f5 => "F5",
            .f6 => "F6",
            .f7 => "F7",
            .f8 => "F8",
            .f9 => "F9",
            .f10 => "F10",
            .f11 => "F11",
            .l1 => "L1",
            .f12 => "F12",
            .l2 => "L2",
            .f13 => "F13",
            .l3 => "L3",
            .f14 => "F14",
            .l4 => "L4",
            .f15 => "F15",
            .l5 => "L5",
            .f16 => "F16",
            .l6 => "L6",
            .f17 => "F17",
            .l7 => "L7",
            .f18 => "F18",
            .l8 => "L8",
            .f19 => "F19",
            .l9 => "L9",
            .f20 => "F20",
            .l10 => "L10",
            .f21 => "F21",
            .l11 => "L11",
            .f22 => "F22",
            .l12 => "L12",
            .escape => "Escape",
            .print => "Print",
            .insert => "Insert",
            .delete => "Delete",
            .tab => "Tab",
            .linefeed => "LineFeed",
            .backspace => "BackSpace",
            .scroll_lock => "Scroll_Lock",
            .sys_req => "Sys_Req",
            .pause => "Pause",
            .home => "Home",
            .prior => "Prior",
            .page_up => "Page_Up",
            .next => "Next",
            .page_down => "Page_Down",
            .end => "End",
            .begin => "Begin",
            .select => "Select",
            .execute => "Execute",
            .undo => "Undo",
            .redo => "Redo",
            .menu => "Menu",
            .find => "Find",
            .cancel => "Cancel",
            .help => "Help",
            .@"break" => "Break",
            .script_switch => "script_switch",
            .num_lock => "Num_Lock",
            .kp_space => "Kp_Space",
            .kp_tab => "Kp_Tab",
            .kp_enter => "Kp_Enter",
            .kp_f1 => "Kp_F1",
            .kp_f2 => "Kp_F2",
            .kp_f3 => "Kp_F3",
            .kp_f4 => "Kp_F4",
            .kp_home => "Kp_Home",
            .kp_left => "Kp_Left",
            .kp_up => "Kp_Up",
            .kp_right => "Kp_Right",
            .kp_down => "Kp_Down",
            .kp_prior => "Kp_Prior",
            .kp_page_up => "Kp_Page_Up",
            .kp_page_down => "Kp_Page_Down",
            .kp_next => "Kp_Next",
            .kp_end => "Kp_End",
            .kp_begin => "Kp_Begin",
            .kp_insert => "Kp_Insert",
            .kp_delete => "Kp_Delete",
            .kp_equal => "Kp_Equal",
            .kp_multiply => "Kp_Multiply",
            .kp_add => "Kp_Add",
            .kp_separator => "Kp_Separator",
            .kp_subtract => "Kp_Subtract",
            .kp_decimal => "Kp_Decimal",
            .kp_divide => "Kp_Divide",
            .kp_0 => "Kp_0",
            .kp_1 => "Kp_1",
            .kp_2 => "Kp_2",
            .kp_3 => "Kp_3",
            .kp_4 => "Kp_4",
            .kp_5 => "Kp_5",
            .kp_6 => "Kp_6",
            .kp_7 => "Kp_7",
            .kp_8 => "Kp_8",
            .kp_9 => "Kp_9",
            .@"0" => "0",
            .@"1" => "1",
            .@"2" => "2",
            .@"3" => "3",
            .@"4" => "4",
            .@"5" => "5",
            .@"6" => "6",
            .@"7" => "7",
            .@"8" => "8",
            .@"9" => "9",
        };
    }

    pub fn getNumber(value: usize) ?Key {
        return switch (value) {
            0 => .@"0",
            1 => .@"1",
            2 => .@"2",
            3 => .@"3",
            4 => .@"4",
            5 => .@"5",
            6 => .@"6",
            7 => .@"7",
            8 => .@"8",
            9 => .@"9",
            else => null,
        };
    }
};
