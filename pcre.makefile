SRCS= \
  pcre_byte_order.c \
  pcre_compile.c \
  pcre_config.c \
  pcre_dfa_exec.c \
  pcre_exec.c \
  pcre_fullinfo.c \
  pcre_get.c \
  pcre_globals.c \
  pcre_internal.h \
  pcre_jit_compile.c \
  pcre_maketables.c \
  pcre_newline.c \
  pcre_ord2utf8.c \
  pcre_refcount.c \
  pcre_string_utils.c \
  pcre_study.c \
  pcre_tables.c \
  pcre_ucd.c \
  pcre_valid_utf8.c \
  pcre_version.c \
  pcre_xclass.c \
  ucp.h \
  pcre_chartables.c

all: libpcre.a

.c.o: config.h pcre.h
	cc -c -DHAVE_CONFIG_H -o $@ $<

config.h: config.h.generic
	cp config.h.generic config.h

pcre.h: pcre.h.generic
	cp pcre.h.generic pcre.h

pcre_chartables.c: pcre_chartables.c.dist
	cp pcre_chartables.c.dist pcre_chartables.c

libpcre.a: $(SRCS:.c=.o) config.h
	rm -f $@
	ar rc $@ $>
