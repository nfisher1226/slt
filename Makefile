PROGNAME   ?= cslt
CXXPROG    ?= cppslt
PREFIX     ?= /usr/local
BINDIR     ?= $(DESTDIR)$(PREFIX)/bin
MANDIR     ?= $(DESTDIR)$(PREFIX)/share/man
# Don't change here down
INSTALLDIRS = $(BINDIR) $(MANDIR)/man1
CC         ?= gcc
CXX        ?= g++
CFLAGS     += -std=c99 -Wall -pedantic
CXXFLAGS   += -std=c++17
LIBS       += -lm
VPATH      += src
VPATH      += man

all: $(PROGNAME) $(CXXPROG)

$(PROGNAME): cslt.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

$(CXXPROG): cppslt.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

install: $(BINDIR)/$(PROGNAME) $(BINDIR)/$(CXXPROG) $(MANDIR)/man1/$(PROGNAME).1

install-strip: $(BINDIR)/$(PROGNAME) $(MANDIR)/man1/$(PROGNAME).1
	strip -s $<

$(BINDIR)/$(PROGNAME): $(PROGNAME) | $(BINDIR)
	install -m0755 $< $@

$(BINDIR)/$(CXXPROG): $(PROGNAME) | $(BINDIR)
	install -m0755 $< $@

$(MANDIR)/man1/$(PROGNAME).1: cslt.1 | $(MANDIR)/man1
	install -m0644 $< $@

$(INSTALLDIRS):
	install -d $@

clean:
	rm -rf $(PROGNAME) cppslt

uninstall:
	rm -rf $(BINDIR)/$(PROGNAME) $(MANDIR)/man1/$(PROGNAME).1

.PHONY: all clean install install-strip
