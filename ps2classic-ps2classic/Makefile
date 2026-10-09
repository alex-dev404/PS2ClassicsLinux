TOOLS = ps2classic
COMMON_SOURCES = tools.c aes.c sha1.c iso.c
ALL_OBJECTS = $(COMMON_OBJECTS) mingw_mmap.o $(addsuffix .o, $(TOOLS))
DEPS = Makefile tools.h types.h aes.h sha1.h iso.h mingw_mmap.h

CC ?= gcc
CFLAGS ?= -g -O3 -W
CPPFLAGS += -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
LDFLAGS ?=
LDLIBS ?=

UNAME_S := $(shell uname -s)
ifneq ($(findstring MINGW,$(UNAME_S)),)
CPPFLAGS += -DWIN32 -D__MSVCRT__ -D__USE_MINGW_FSEEK
COMMON_SOURCES += mingw_mmap.c
LDLIBS += -ladvapi32
endif

COMMON_OBJECTS = $(COMMON_SOURCES:.c=.o)

.PHONY: all check clean

all: $(TOOLS)

$(TOOLS): %: %.o $(COMMON_OBJECTS) $(DEPS)
	$(CC) $(CFLAGS) -o $@ $< $(COMMON_OBJECTS) $(LDFLAGS) $(LDLIBS)

%.o: %.c $(DEPS)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

check: $(TOOLS)
	@./ps2classic | grep -q '^usage:'
	@bash -n ./ps2classic-gui ./setup-pop-fe2.sh ../install-desktop.sh ./tests/test-gui.sh
	@bash ./tests/test-gui.sh
	@bash ./tests/test-installer.sh

clean:
	rm -f $(ALL_OBJECTS) $(TOOLS)
