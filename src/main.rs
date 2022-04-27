/*
 *----------------------------------------------------------------------
 *           "THE BEER-WARE LICENSE" (Revision 42):
 * <jeang3nie@HitchHiker-Linux.org> wrote this file. As long as you
 * retain this notice you can do whatever you want with this stuff. If
 * we meet some day, and you think this stuff is worth it, you can buy
 * me a beer in return.
 * ---------------------------------------------------------------------
 *            ______   _______  _          _________
 *           (  __  \ (  ___  )( (    /|( )\__   __/
 *           | (  \  )| (   ) ||  \  ( ||/    ) (
 *           | |   ) || |   | ||   \ | |      | |
 *           | |   | || |   | || (\ \) |      | |
 *           | |   ) || |   | || | \   |      | |
 *           | (__/  )| (___) || )  \  |      | |
 *           (______/ (_______)|/    )_)      )_(
 *
 *         _______  _______  _       _________ _______
 *        (  ____ )(  ___  )( \    /|\__   __/(  ____ \
 *        | (    )|| (   ) ||  \  ( |   ) (   | (    |/
 *        | (____)|| (___) ||   \ | |   | |   | |
 *        |  _____)|  ___  || (\ \) |   | |   | |
 *        | (      | (   ) || | \   |   | |   | |
 *        | )      | )   ( || )  \  |___) (___| (____|\
 *        |/       |/     \||/    \_)\_______/(_______/
 *
 */

use clap::{crate_version, App, Arg};
use core::f64::consts::PI;
use std::process;

struct Specs {
    depth: f64,
    length: f64,
    offset: f64,
    hex: bool,
}

impl Specs {
    fn print_sine(&self, index: &f64) {
        let hypotenuse = (self.depth - 1.0) / 2.0;
        let rads_per_index = (2.0 * PI) / self.length;
        let rads = index * rads_per_index;
        let entry = ((rads.sin() * hypotenuse) + hypotenuse + self.offset).round() as u64;
        if self.hex {
            print!("{:#x}", entry);
        } else {
            print!("{}", entry);
        }
        if index < &((self.length) - 1.0) {
            print!(", ");
            if (index + 1.0) % 12.0 == 0.0 {
                print!("\n    ");
            }
        } else {
            println!("\n}};");
        }
    }
}

fn main() {
    let matches = App::new("rslt")
        .version(crate_version!())
        .author("The JeanG3nie <jeang3nie@hitchhiker-linux.org>")
        .about("Generate a Sine Look Up Table in array format")
        .arg(
            Arg::new("DEPTH")
                .about("The depth or amplitude")
                .short('d')
                .long("depth")
                .default_value("16")
                .takes_value(true),
        )
        .arg(
            Arg::new("LENGTH")
                .about("The number of entries")
                .short('l')
                .long("length")
                .default_value("16")
                .takes_value(true),
        )
        .arg(
            Arg::new("OFFSET")
                .about("Offset the amplitude from zero")
                .short('o')
                .long("offset")
                .default_value("0")
                .takes_value(true),
        )
        .arg(
            Arg::new("HEX")
                .about("Return results in hex format")
                .short('x')
                .long("hex"),
        )
        .get_matches();
    let offset: f64 = match matches.value_of_t("OFFSET") {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: {}", e);
            process::exit(1);
        }
    };

    let specs = Specs {
        depth: match matches.value_of_t::<f64>("DEPTH") {
            Ok(c) => c - offset,
            Err(e) => {
                eprintln!("error: {}", e);
                process::exit(1);
            }
        },
        length: match matches.value_of_t("LENGTH") {
            Ok(c) => c,
            Err(e) => {
                eprintln!("error: {}", e);
                process::exit(1);
            }
        },
        offset,
        hex: matches.is_present("HEX"),
    };
    if specs.depth <= (specs.offset) {
        eprintln!("ERROR: depth smaller than offset");
        process::exit(1);
    }

    print!("{{\n    ");
    for i in 0..(specs.length as u64) {
        specs.print_sine(&(i as f64));
    }
}
