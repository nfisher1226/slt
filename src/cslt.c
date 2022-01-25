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
#define _XOPEN_SOURCE

#include <ctype.h>
#include <errno.h>   // errno
#include <libgen.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static const char *__progname;

static void usage() {
  fprintf(stderr, "usage: %s [-l length] [-d depth] [-o offset] [-hx]\n",
          __progname);
}

/* Returns the computed value for each entry in the LUT */
int computeSine(double index, unsigned int length, unsigned int depth) {
  double hypotenuse = ((float)depth - 1) / 2;
  double radsPerIndex = (2 * M_PI) / length;
  double rads = index * radsPerIndex;
  double value = (sin(rads) * hypotenuse) + hypotenuse;
  return (unsigned int)round(value);
}

long parselong(char *buf) {
  errno = 0;
  char *endptr;
  int num = strtol(optarg, &endptr, 10);
  if (errno != 0) {
        perror("Error parsing integer from input: ");
        exit(EXIT_FAILURE);
  } else if (num == 0 && endptr == optarg) {
        fprintf(stderr, "Error: invalid input: %s\n", optarg);
        exit(EXIT_FAILURE);
  } else if (*endptr != '\0') {
        fprintf(stderr, "Error: invalid input: %s\n", optarg);
        exit(EXIT_FAILURE);
  }
  return num;
}

int main(int argc, char *argv[]) {
  unsigned int c, length = 16, depth = 16, line = 0, offset = 0, xflag = 0;
  __progname = basename(argv[0]);

  while ((c = getopt(argc, argv, "hd:l:o:x")) != -1)
    switch (c) {
    case 'h':
      usage();
      return 0;
      break;
    case 'd':
      depth = parselong(optarg);
      break;
    case 'l':
      length = parselong(optarg);
      break;
    case 'o':
      offset = parselong(optarg);
      break;
    case 'x':
      xflag = 1;
      break;
    case '?':
      if (optopt == 'l' || optopt == 'd' || optopt == 'o')
        fprintf(stderr, "Option -%c requires an argument.\n", optopt);
      else if (isprint(optopt)) {
        usage();
        exit(1);
      }
    }

  if (depth <= offset) {
    fprintf(stderr, "ERROR: depth smaller than offset");
    exit(EXIT_FAILURE);
  }
  depth = depth - offset;
  double index = 0;

  printf("{\n    ");

  while (index < length) {
    if (line == 12) {
      printf("\n    ");
      line = 0;
    }
    unsigned int entry = computeSine(index, length, depth) + offset;
    if (xflag)
      printf("0x%x", entry);
    else
      printf("%i", entry);

    if (index < length - 1)
      printf(", ");
    else
      puts("\n};");
    index++;
    line++;
  }
  return 0;
}
