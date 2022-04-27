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

use fmt;
use getopt;
use math;
use os;
use strconv;

type specs = struct {
	depth: uint,
	length: uint,
	offs: uint,
	hex: uint,
};

fn printSine(idx: uint, sp: specs) void = {
	let hypotenuse: f64 = (sp.depth: f64 - 1.0) / 2.0;
	let radsPerIndex: f64 = (2.0 * math::PI) / sp.length: f64;
	let rads: f64 = idx: f64 * radsPerIndex;
	let val: f64 = (math::sinf64(rads) * hypotenuse) + hypotenuse;
	let val: uint = math::roundf64(val): uint + sp.offs;
	if (sp.hex == 0) {
		fmt::printf("{}", val)!;
	} else {
 		fmt::printf("0x{:x}", val)!;
	};
};

export fn main() void = {
	const help: []getopt::help = [
		"Generate a Sine Look Up Table in array format",
		('d', "depth", "The depth or amplitude"),
		('l', "length", "The number of entries in the array"),
		('o', "offset", "Offset the amplitude from zero"),
		('x', "Return results in hex format"),
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);

	let sp = specs {
		depth = 16,
		length = 16,
		offs = 0,
		hex = 0,
	};

	for (let i = 0z; i < len(cmd.opts); i += 1) {
		const opt = cmd.opts[i];
		switch (opt.0) {
		case 'd' =>
			match (strconv::stou(opt.1)) {
			case let depth: uint =>
				sp.depth = depth;
			case strconv::invalid =>
				fmt::fatal("Invalid depth");
			case strconv::overflow =>
				fmt::fatal("Depth exceeds range");
			};
		case 'l' =>
			match (strconv::stou(opt.1)) {
			case let length: uint =>
				sp.length = length;
			case strconv::invalid =>
				fmt::fatal("Invalid length");
			case strconv::overflow =>
				fmt::fatal("Length exceeds range");
			};
		case 'o' =>
			match (strconv::stou(opt.1)) {
			case let offs: uint =>
				sp.offs = offs;
			case strconv::invalid =>
				fmt::fatal("Invalid offset");
			case strconv::overflow =>
				fmt::fatal("Offset exceeds range");
			};
		case 'x' =>
			sp.hex = 1;
		};
	};

	if (len(cmd.args) != 0) {
		getopt::printusage(os::stderr, os::args[0], help);
		os::exit(1);
	};

	if (sp.offs >= sp.depth) {
		fmt::fatal("Offset exceeds depth");
	} else {
		sp.depth -= sp.offs;
	};

	fmt::print("{\n    ")!;

	let idx = 0u;
	for (idx < sp.length; idx += 1) {
		if (idx % 12 == 0) {
			fmt::print("\n    ")!;
		};
		printSine(idx, sp);
		if (idx < sp.length - 1) {
			fmt::print(", ")!;
		};
	};
	fmt::println("\n};")!;
};
