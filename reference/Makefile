SHELL    = /bin/sh
CC       = gcc

TARGET   = wavegain
DEFS     = -DHAVE_CONFIG_H
LIBS     = -lm
SOURCES  = $(shell echo *.c)
HEADERS  = $(shell echo *.h)
OBJECTS  = $(SOURCES:.c=.o)

prefix   = /usr/local
bindir   = $(prefix)/bin

all: $(TARGET)

debug: CFLAGS += -g -O0 -Wall -Wextra
debug: clean all

release: CFLAGS += -s
release: clean all

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(DEFS) -c -o $@ $< $(LIBS)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(DEFS) -o $(TARGET) $(OBJECTS) $(LIBS)

install: $(TARGET)
	install -s -D $(TARGET) $(DESTDIR)$(bindir)/$(TARGET)

uninstall:
	rm -f $(DESTDIR)$(bindir)/$(TARGET)

clean:
	rm -f $(TARGET) *.o

distclean: clean

.PHONY : all debug release install uninstall clean distclean
