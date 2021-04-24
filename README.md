# slt
## Introduction
In DSP applications a common task is the generation of a sine wave,
often for use as a low frequency oscillator **(LFO)** to modulate an audio
signal. As an example, phasers, flangers, vibrato and tremolo all use an
LFO to modulate the signal.

While it is possible to generate this signal on the fly, it is always
faster to just retrieve the already computed values from an array using
a look up table **(LUT)**. This is especially true in environments where
computing power is limited (such as a microcontroller based guitar pedal).
While there are a number of online tools available that will generate a
LUT for you, I prefer to not rely on tools in the cloud for my programming
and wanted a small command line tool for the job.
## Description
Given a set of parameters, **slt** will generate a LUT in the form of an
array, ready to paste into a C, C++ or Wiring (Arduino) program.The command
line parameters are as follows:
* -d - depth or amplitude as an integer value (default 16)
* -l - length or number of elements (default 16)
* -o - offset the computed values by this amount from zero

  This is useful for matching the output to the hardware being used to
  actually render the audio. For instance, many effects use an LED driven
  optocoupler, and an LED will not switch on until the forward voltage
  reaches a minimum barrier.

* -x - output the values in hex instead of as integers
## Three complete versions
The program was originally coded in C as it's a language that I'm fairly
competent in. The distribution now also includes a complete rewrite in
Rust, and another in Zig, both undertaken as learning exercises. The
three versions are functionally similar, with some caveats.

The C version gives an extremely terse usage statement when invoked with
the -h flag and only accepts short form options. The included Unix man
page is the primary source of documentation.

The Rust version, in comparison, has builtin documentation provided by
the excellent clap crate used for option parsing. Invoking the binary
with either the -h flag or --help pulls up pretty much all of the same
information as is included in the manual page. As a side effect of using
clap, the binary also accepts GNU style long options.

The Zig version, like the Rust version, includes long options and is
pretty much self documenting due to the usage of the zig-clap library.
Note that unlike Rust Zig does not have, as yet, a bundled package
manager. There are a few unofficial projects which implement this
functionality, notably [gyro](https://github.com/mattnite/gyro). However
I wanted to stick to only the official tooling for each language, so I
chose to include the zig-clap source and build and link it using the Zig
build system.

The three binaries are roughly equivalent in speed, but the rust version
incurs a significant size penaly due to the static linking of Rust's
libstd and the clap crate. The resulting binary is 764K versus the tiny
16K produced with the dynamically linked C binary. This is a fundamental
difference between the two languages currently. The Zig binary falls
somewhere in the middle, depending on the options given to 
```zig build```, but when compiled in release-safe mode (which is what
most will choose to use) comes in at 144k but is a fully **static**
binary. In comparison Rust links in all Rust code statically, but then
links dynamically to libc, libm, libpthread, libgcc and libdl. The C
original is of course a traditional dynamically linked binary.

Note that we can take **some** steps to reduce the size of the Rust
binary, by changing some settings in Cargo.toml.
```Toml
[profile.release]
panic = 'abort'
lto = true
codegen-units = 1
```
This brings the binary size down to 632k. Still not great, but worth it.
At this point I might mention though, the Zig version can also be
compiled using release-small and net you a fully static 60k binary, which
is quite impressive.
