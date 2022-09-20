//
//----------------------------------------------------------------------
//           "THE BEER-WARE LICENSE" (Revision 42):
// <jeang3nie@HitchHiker-Linux.org> wrote this file. As long as you
// retain this notice you can do whatever you want with this stuff. If
// we meet some day, and you think this stuff is worth it, you can buy
// me a beer in return.
// ---------------------------------------------------------------------
//            ______   _______  _          _________
//           (  __  \ (  ___  )( (    /|( )\__   __/
//           | (  \  )| (   ) ||  \  ( ||/    ) (
//           | |   ) || |   | ||   \ | |      | |
//           | |   | || |   | || (\ \) |      | |
//           | |   ) || |   | || | \   |      | |
//           | (__/  )| (___) || )  \  |      | |
//           (______/ (_______)|/    )_)      )_(
//
//         _______  _______  _       _________ _______
//        (  ____ )(  ___  )( \    /|\__   __/(  ____ \
//        | (    )|| (   ) ||  \  ( |   ) (   | (    |/
//        | (____)|| (___) ||   \ | |   | |   | |
//        |  _____)|  ___  || (\ \) |   | |   | |
//        | (      | (   ) || | \   |   | |   | |
//        | )      | )   ( || )  \  |___) (___| (____|\
//        |/       |/     \||/    \_)\_______/(_______/
//

const std = @import("std");
const clap = @import("zig-clap");
const allocator = std.heap.page_allocator;
const fmt = std.fmt;
const math = std.math;
const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

const params = clap.parseParamsComptime(
    \\-h, --help             Display this help and exit.
    \\-d, --depth  <usize>   The depth or amplitude.
    \\-l, --length <usize>   The number of entries.
    \\-o, --offset <usize>   Offset the amplitude from zero.
    \\-x, --hex              Return results in hex format.
    \\
);

const Specs = struct {
    depth: f64,
    length: f64,
    offset: f64,
    hex: bool,

    fn print_sine(self: Specs, index: f64) !void {
        const hypotenuse = (self.depth - 1.0) / 2.0;
        const rads_per_index = (2.0 * math.pi) / self.length;
        const rads = index * rads_per_index;
        const entry = math.round((math.sin(rads) * hypotenuse) + hypotenuse + self.offset);
        if (self.hex) {
            try stdout.print("0x{x}", .{@floatToInt(u64, entry)});
        } else {
            try stdout.print("{d:.0}", .{@floatToInt(u64, entry)});
        }
        if (index < (self.length - 1.0)) {
            try stdout.print(", ", .{});
            if ((@floatToInt(u64, index) + 1) % 12 == 0) {
                try stdout.print("\n    ", .{});
            }
        } else {
            try stdout.print("\n}};\n", .{});
        }
    }
};

pub fn main() anyerror!void {
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag
    }) catch |err| {
        diag.report(stderr, err) catch {};
        return err;
    };
    defer res.deinit();
    if (res.args.help) {
        usage(0);
    }

    const depth: f64 = if (res.args.depth) |d| @intToFloat(f64, d) else 16.0;
    const length: f64 = if (res.args.length) |l| @intToFloat(f64, l) else 16.0;
    const offset: f64 = if (res.args.offset) |o| @intToFloat(f64, o) else 0.0;
    if (depth <= offset) {
        try stderr.print("ERROR: depth smaller than offset\n", .{});
        usage(1);
    }

    try stdout.print("{{\n    ", .{});

    const specs = Specs{
        .depth = depth - offset,
        .length = length,
        .offset = offset,
        .hex = (res.args.hex),
    };
    var i: f64 = 0.0;
    while (i < length) {
        try specs.print_sine(i);
        i += 1.0;
    }
}

fn usage(status: u8) void {
    stderr.print("Usage: {s} ", .{"zslt"}) catch unreachable;
    clap.usage(stderr, clap.Help, &params) catch unreachable;
    stderr.print("\nFlags: \n", .{}) catch unreachable;
    clap.help(stderr, clap.Help, &params, .{}) catch unreachable;
    std.process.exit(status);
}
