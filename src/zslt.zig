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
const PI = std.math.pi;
const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

const params = comptime [_]clap.Param(clap.Help){
    clap.parseParam("-h, --help             Display this help and exit.") catch unreachable,
    clap.parseParam("-d, --depth <NUM>      The depth or amplitude.") catch unreachable,
    clap.parseParam("-l, --length <NUM>     The number of entries.") catch unreachable,
    clap.parseParam("-o, --offset <NUM>     Offset the amplitude from zero.") catch unreachable,
    clap.parseParam("-x, --hex              Return results in hex format.") catch unreachable,
};

const Specs = struct {
    depth: f64,
    length: f64,
    offset: f64,
    hex: bool,
    
    fn print_sine(self: Specs, index: f64) !void {
        const hypotenuse = (self.depth - 1.0) / 2.0;
        const rads_per_index = (2.0 * PI) / self.length;
        const rads = index * rads_per_index;
        const entry = std.math.round((std.math.sin(rads) * hypotenuse) + hypotenuse + self.offset);
        if (self.hex) {
            try stdout.print("0x{x}", .{@floatToInt(u64, entry)});
        } else {
            try stdout.print("{d:.0}", .{entry});
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
    var diag: clap.Diagnostic = undefined;
    var args = clap.parse(clap.Help, &params, std.heap.page_allocator, &diag) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer args.deinit();
    if (args.flag("--help")) {
        usage(0);
    }
    
    var depth: f64 = 16.0;
    if (args.option("--depth")) |d| {
        depth = std.fmt.parseFloat(f64, d) catch |e| {
            try stderr.print("{s}\n", .{e});
            usage(1);
            unreachable;
        };
    }
    
    var length: f64 = 16.0;
    if (args.option("--length")) |l| {
        length = std.fmt.parseFloat(f64, l) catch |e| {
            try stderr.print("{s}\n", .{e});
            usage(1);
            unreachable;
        };
    }
    
    var offset: f64 = 0.0;
    if (args.option("--offset")) |o| {
        offset = std.fmt.parseFloat(f64, o) catch |e| {
            try stderr.print("{s}\n", .{e});
            usage(1);
            unreachable;
        };
    }
    
    if (depth <= offset) {
        try stderr.print("ERROR: depth smaller than offset", .{});
        usage(1);
    }

    try stdout.print("{{\n    ", .{});
    
    const specs = Specs {
        .depth = depth - offset,
        .length = length,
        .offset = offset,
        .hex = (args.flag("--hex")),
    };
    var i: f64 = 0.0;
    while (i < length) {
        try specs.print_sine(i);
        i += 1.0;
    }
}

fn usage(status: u8) void {
    stderr.print("Usage: {s} ", .{"zslt"}) catch unreachable;
    clap.usage(stderr, &params) catch unreachable;
    stderr.print("\nFlags: \n", .{}) catch unreachable;
    clap.help(stderr, &params) catch unreachable;
    std.process.exit(status);
}
