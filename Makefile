PROGNAME   ?= cslt
PREFIX     ?= /usr/local
BINDIR     ?= $(DESTDIR)$(PREFIX)/bin
MANDIR     ?= $(DESTDIR)$(PREFIX)/share/man
# Don't change here down
INSTALLDIRS = $(BINDIR) $(MANDIR)/man1
CFLAGS     += -std=c99 -Wall -pedantic
LIBS       += -lm
VPATH      += src
VPATH      += man

all: $(PROGNAME)

$(PROGNAME): cslt.c
	cc $(CFLAGS) -o $@ $< $(LIBS)

install: $(BINDIR)/$(PROGNAME) $(MANDIR)/man1/$(PROGNAME).1

install-strip: $(BINDIR)/$(PROGNAME) $(MANDIR)/man1/$(PROGNAME).1
	strip -s $<

$(BINDIR)/$(PROGNAME): $(PROGNAME) | $(BINDIR)
	install -m0755 $< $@

$(MANDIR)/man1/$(PROGNAME).1: slut.1 | $(MANDIR)/man1
	install -m0644 $< $@

$(INSTALLDIRS):
	install -d $@

clean:
	rm -rf $(PROGNAME)

uninstall:
	rm -rf $(BINDIR)/$(PROGNAME) $(MANDIR)/man1/$(PROGNAME).1

.PHONY: all clean install install-strip
