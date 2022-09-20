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
## Seven complete versions
The program was originally coded in C as it's a language that I'm fairly
competent in. The distribution now also includes a complete rewrite in
Rust, and another in Zig, both undertaken as learning exercises. For the sake of
completeness, I then decided to try Python. And after that, as I've been curious
about Nim, I ported it to that language as well. Now that I know this program
inside and out, I decided to try and write in in Hare when that language was
released as well. I know, I have a problem.

All versions give identical output but have some slight differences in function.

The C version gives an extremely terse usage statement when invoked with
the -h flag and only accepts short form options. The included Unix man
page is the primary source of documentation. To build the C version just use the
included Makefile.

```sh
make
make install
```
The Hare version functions much the same as the C version accepting only short
form options. To build the Hare version (after installing Hare on your computer)
invoke the compiler directly.

```sh
hare build -o hslt src/hslt.ha
install -s hslt /usr/local/bin
```


The Rust version, in comparison, has builtin documentation provided by
the excellent clap crate used for option parsing. Invoking the binary
with either the -h flag or --help pulls up pretty much all of the same
information as is included in the manual page. As a side effect of using
clap, the binary also accepts GNU style long options. To build the Rust version
use cargo.

```sh
cargo build --release
install -s target/release/rslt /usr/local/bin
```

The Zig version, like the Rust version, includes long options and is
pretty much self documenting due to the usage of the zig-clap library.
Note that unlike Rust Zig does not have, as yet, a bundled package
manager. There are a few unofficial projects which implement this
functionality, notably [gyro](https://github.com/mattnite/gyro). However
I wanted to stick to only the official tooling for each language, so I
chose to include the zig-clap source and build and link it using the Zig
build system. To build the Zig version, first fetch the zig-clap submodule, then
build it with zig.

```sh
git submodule init
git submodule update
cd zig-clap
git checkout zig-master
cd ../
zig build -Drelease-safe=true
install -s zslt zig-cache/bin/zslt
```

The python version is, of course, not a binary. You can just install it into
your path and make it executable. This version was the smallest so far in terms
of LOC, mostly due to Python's syntax being very concise and not requiring
braces and semicolons. It is debatable to me whether this actually makes the
code more or less readable. I personally like the clearly delineated blocks of
the compiled languages, but Python has the benefit of being nearly as ubiquitous
as C, in that most Linux distros will have it in the default install and it is
relatively easy to install on other platforms which may not have such easy access
to a compiler. Interestingly, once you get past the command line parsing, what
you get is very close to a straight translation from C to Python. This version
also benefits from not requiring any external libraries for command line parsing,
as Python's standard library is very comprehensive.


```sh
install -sm755 src/slt.py /usr/local/bin
```

The Nim implementation is very similar in appearance and flow to the Python
version and also manages the task with no external dependencies. The resulting
executable links dynamically to libc, libm, libdl and librt and weighs in at
152k after stripping. It's an interesting language, but the documentation, while
comprehensive, is somewhat lacking in examples. My main grip, however, is that
parsing options with the included getopt function gives the resulting binary a
rather non-standard syntax. It will accept ```-f=flag```, ```-f:flag```,
```--flag=flag``` or ```--flag:flag```, but not ```-fflag``` or ```-f flag``` as
is commonly in use in most command line parsers. There are, of course, some third
party libraries that can be used instead of nim's getopt, or one could try
calling into C. But I would think it preferable that if a standard library
includes a command line parser that parser would follow expected behaviors.

The nim version requires the nim compiler to build.
```sh
nim compile src/nslt
```

The fortran implementation is a relatively recent addition as it's a language
which I have always been curious about but it is so different as to require some
effort to pick up. I have to say, I can see fortran being useful as it's syntax
is quite a bit simpler than it seems at first blush, and the language is quite
complete already in what it gives you. It is also much more active than I expected
for such an old language, and even has a Cargo inspired package manager named fpm.
To check it out, install the Gnu gfortran compiler and the fpm package manager
(available on GitHub).

```sh
fpm build
```

The six binaries are roughly equivalent in speed, but the rust version
incurs a significant size penaly due to the static linking of Rust's
libstd and the clap crate. The resulting binary is 764K versus the tiny
16K produced with the dynamically linked C binary. This is a fundamental
difference between the two languages currently. The Zig binary falls
somewhere in the middle, depending on the options given to
```zig build```, but when compiled in release-safe mode (which is what
most will choose to use) comes in at 144k but is a fully **static**
binary. In comparison Rust links in all Rust code statically, but then
links dynamically to libc, libm, libpthread, libgcc and libdl. The C
original is of course a traditional dynamically linked binary as is the Nim
binary, which is slightly smaller that Zig but links dynamically to system
libraries.

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
