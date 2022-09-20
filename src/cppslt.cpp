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

#include <cmath>
#include <filesystem>
#include <iostream>
#include <unistd.h>

using namespace std;

string progname;

class WaveForm {
  unsigned int length, depth;

public:
  WaveForm() {
    length = 16;
    depth = 16;
  }

  void set_length(unsigned int l) { length = l; }

  void set_depth(unsigned int d) { depth = d; }

  void offset_depth(unsigned int offset) { depth -= offset; }

  unsigned int get_depth() { return depth; }

  unsigned int get_length() { return length; }

  /* Returns the computed value for each entry in the LUT */
  unsigned int get_node(int index) {
    double hypotenuse = ((double)depth - 1) / 2;
    double radsPerIndex = (2 * M_PI) / (double)length;
    double rads = (double)index * radsPerIndex;
    double value = (sin(rads) * hypotenuse) + hypotenuse;
    return (unsigned int)round(value);
  }
};

void usage() {
  cerr << "usage: " << progname << " [-l length] [-d depth] [-o offset] [-hx]"
       << endl;
}

int parseint(char *buf) {
  errno = 0;
  char *endptr;
  int num = (int)strtol(optarg, &endptr, 10);
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
  unsigned int c, line = 0, offset = 0;
  bool hx = false;
  WaveForm wave;
  progname = filesystem::path(argv[0]).filename().string();

  while ((c = getopt(argc, argv, "hd:l:o:x")) != -1)
    switch (c) {
    case 'h':
      usage();
      return 0;
      break;
    case 'd':
      wave.set_depth(parseint(optarg));
      break;
    case 'l':
      wave.set_length(parseint(optarg));
      break;
    case 'o':
      offset = parseint(optarg);
      break;
    case 'x':
      hx = true;
      break;
    case '?':
      if (optopt == 'l' || optopt == 'd' || optopt == 'o') {
        cerr << "Option -" << (char)optopt << " requires an argument." << endl;
        usage();
        exit(1);
      } else if (isprint(optopt)) {
        usage();
        exit(1);
      }
    }

  if (wave.get_depth() <= offset) {
    cerr << "ERROR: depth smaller than offset" << endl;
    exit(EXIT_FAILURE);
  }
  wave.offset_depth(offset);
  double index = 0;

  cout << "{\n    ";

  while (index < wave.get_length()) {
    if (line != 0 && line % 12 == 0) {
      cout << "\n    ";
    }
    unsigned int node = wave.get_node(index) + offset;
    if (hx)
      cout << "0x" << hex << node;
    else
      cout << node;

    if (index < wave.get_length() - 1)
      cout << ", ";
    else
      cout << "\n};" << endl;
    index++;
    line++;
  }
  return 0;
}
