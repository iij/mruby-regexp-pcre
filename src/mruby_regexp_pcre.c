#include <mruby.h>
#include <mruby/class.h>
#include <mruby/array.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include <mruby/variable.h>

#include <stdio.h>
#include <string.h>
#include <pcre.h>

#define MRUBY_REGEXP_IGNORECASE         0x01
#define MRUBY_REGEXP_EXTENDED           0x02
#define MRUBY_REGEXP_MULTILINE          0x04

struct mrb_regexp_pcre {
  pcre *re;
};

struct mrb_matchdata {
  mrb_int length;
  int *ovector;
};

void
mrb_regexp_free(mrb_state *mrb, void *ptr)
{
  struct mrb_regexp_pcre *mrb_re = ptr;

  if (mrb_re != NULL) {
    if (mrb_re->re != NULL) {
      pcre_free(mrb_re->re);
    }
    mrb_free(mrb, mrb_re);
  }
}

static void
mrb_matchdata_free(mrb_state *mrb, void *ptr)
{
  struct mrb_matchdata *mrb_md = ptr;

  if (mrb_md != NULL) {
    if (mrb_md->ovector != NULL) {
      mrb_free(mrb, mrb_md->ovector);
    }
    mrb_free(mrb, mrb_md);
  }
}

static struct mrb_data_type mrb_regexp_type = { "Regexp", mrb_regexp_free };
static struct mrb_data_type mrb_matchdata_type = { "MatchData", mrb_matchdata_free };


static int
mrb_mruby_to_pcre_options(mrb_value options)
{
  int coptions = PCRE_MULTILINE;

  if (mrb_fixnum_p(options)) {
    int nopt = mrb_fixnum(options);
    if (nopt & MRUBY_REGEXP_IGNORECASE) coptions |= PCRE_CASELESS;
    if (nopt & MRUBY_REGEXP_MULTILINE)  coptions |= PCRE_DOTALL;
    if (nopt & MRUBY_REGEXP_EXTENDED)   coptions |= PCRE_EXTENDED;
  } else if (mrb_string_p(options)) {
    const char *sptr = RSTRING_PTR(options);
    size_t slen = RSTRING_LEN(options);
    if (memchr(sptr, 'i', slen)) coptions |= PCRE_CASELESS;
    if (memchr(sptr, 'm', slen)) coptions |= PCRE_DOTALL;
    if (memchr(sptr, 'x', slen)) coptions |= PCRE_EXTENDED;
  } else if (mrb_test(options)) { // other "true" values
    coptions |= PCRE_CASELESS;
  }

  return coptions;
}

static int
mrb_pcre_to_mruby_options(int coptions)
{
  int options = 0;

  if (coptions & PCRE_CASELESS)  options |= MRUBY_REGEXP_IGNORECASE;
  if (coptions & PCRE_DOTALL)    options |= MRUBY_REGEXP_MULTILINE;
  if (coptions & PCRE_EXTENDED)  options |= MRUBY_REGEXP_EXTENDED;

  return options;
}

mrb_value
regexp_pcre_initialize(mrb_state *mrb, mrb_value self)
{
  int erroff = 0, coptions;
  const char *errstr = NULL;
  struct mrb_regexp_pcre *reg = NULL;
  mrb_value source, opt = mrb_nil_value();
  unsigned char *name_table, *tabptr;
  int i, namecount, name_entry_size;

  reg = (struct mrb_regexp_pcre *)DATA_PTR(self);
  if (reg) {
    mrb_regexp_free(mrb, reg);
  }
  DATA_TYPE(self) = &mrb_regexp_type;
  DATA_PTR(self) = NULL;

  mrb_get_args(mrb, "S|o", &source, &opt);

  reg = mrb_malloc(mrb, sizeof(struct mrb_regexp_pcre));
  reg->re = NULL;
  DATA_PTR(self) = reg;

  coptions = mrb_mruby_to_pcre_options(opt);
  source = mrb_str_new(mrb, RSTRING_PTR(source), RSTRING_LEN(source));
  reg->re = pcre_compile(RSTRING_PTR(source), coptions, &errstr, &erroff, NULL);
  if (reg->re == NULL) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid regular expression");
  }
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@source"), source);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@options"), mrb_fixnum_value(mrb_pcre_to_mruby_options(coptions)));

  pcre_fullinfo(reg->re, NULL, PCRE_INFO_NAMECOUNT, &namecount);
  if (namecount > 0) {
    pcre_fullinfo(reg->re, NULL, PCRE_INFO_NAMETABLE, &name_table);
    pcre_fullinfo(reg->re, NULL, PCRE_INFO_NAMEENTRYSIZE, &name_entry_size);
    tabptr = name_table;
    for (i = 0; i < namecount; i++) {
      int n = (tabptr[0] << 8) | tabptr[1];
      mrb_funcall(mrb, self, "name_push", 2, mrb_str_new(mrb, (const char *)(tabptr + 2), strlen((const char *)tabptr + 2)), mrb_fixnum_value(n));
      tabptr += name_entry_size;
    }
  } 

  return self;
}

mrb_value
regexp_pcre_match(mrb_state *mrb, mrb_value self)
{
  struct mrb_matchdata *mrb_md;
  int rc;
  int ccount, matchlen;
  int *match;
  struct RClass *c;
  mrb_value md, str;
  mrb_int i, pos;
  pcre_extra extra;
  struct mrb_regexp_pcre *reg;

  reg = (struct mrb_regexp_pcre *)mrb_get_datatype(mrb, self, &mrb_regexp_type);
  if (!reg)
    return mrb_nil_value();

  pos = 0;
  mrb_get_args(mrb, "S|i", &str, &pos);

  // XXX: RSTRING_LEN(str) >= pos ...

  rc = pcre_fullinfo(reg->re, NULL, PCRE_INFO_CAPTURECOUNT, &ccount);
  if (rc < 0) {
    /* fullinfo error */
    return mrb_nil_value();
  }
  matchlen = ccount + 1;
  match = mrb_malloc(mrb, sizeof(int) * matchlen * 3);

  extra.flags = PCRE_EXTRA_MATCH_LIMIT_RECURSION;
  extra.match_limit_recursion = 1000;
  rc = pcre_exec(reg->re, &extra, RSTRING_PTR(str), RSTRING_LEN(str), pos, 0, match, matchlen * 3);
  if (rc < 0) {
    mrb_free(mrb, match);
    return mrb_nil_value();
  }

  /* XXX: need current scope */
  mrb_obj_iv_set(mrb, (struct RObject *)mrb_class_real(RDATA(self)->c), mrb_intern_lit(mrb, "@last_match"), mrb_nil_value());

  c = mrb_class_get(mrb, "MatchData");
  md = mrb_funcall(mrb, mrb_obj_value(c), "new", 0);

  mrb_md = (struct mrb_matchdata *)mrb_get_datatype(mrb, md, &mrb_matchdata_type);
  mrb_md->ovector = match;
  mrb_md->length = matchlen;

  mrb_iv_set(mrb, md, mrb_intern_lit(mrb, "@regexp"), self);
  mrb_iv_set(mrb, md, mrb_intern_lit(mrb, "@string"), mrb_str_dup(mrb, str));
  /* XXX: need current scope */
  mrb_obj_iv_set(mrb, (struct RObject *)mrb_class_real(RDATA(self)->c), mrb_intern_lit(mrb, "@last_match"), md);

  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$~"), md);
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$&"), mrb_funcall(mrb, md, "to_s", 0));
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$`"), mrb_funcall(mrb, md, "pre_match", 0));
  mrb_gv_set(mrb, mrb_intern_lit(mrb, "$'"), mrb_funcall(mrb, md, "post_match", 0));

  for (i = 1; i < 10; i++) {
    char sym[8];
    snprintf(sym, sizeof(sym), "$%d", i);
    mrb_gv_set(mrb, mrb_intern_cstr(mrb, sym), mrb_funcall(mrb, md, "[]", 1, mrb_fixnum_value(i)));
  }

  return md;
}

static mrb_value
regexp_equal(mrb_state *mrb, mrb_value self)
{
  mrb_value other;
  struct mrb_regexp_pcre *self_reg, *other_reg;

  mrb_get_args(mrb, "o", &other);
  if (mrb_obj_equal(mrb, self, other)) {
    return mrb_true_value();
  }

  if (mrb_type(other) != MRB_TT_DATA || DATA_TYPE(other) != &mrb_regexp_type) {
    return mrb_false_value();
  }

  self_reg = (struct mrb_regexp_pcre *)DATA_PTR(self);
  other_reg = (struct mrb_regexp_pcre *)DATA_PTR(other);
  if (!self_reg || !other_reg) {
    mrb_raise(mrb, E_RUNTIME_ERROR, "Invalid Regexp");
  }

  if (mrb_str_equal(mrb, mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@source")),
                         mrb_iv_get(mrb, other, mrb_intern_lit(mrb, "@source")))) {
    return mrb_true_value();
  }

  return mrb_false_value();
}

mrb_value
mrb_matchdata_init(mrb_state *mrb, mrb_value self)
{
  struct mrb_matchdata *mrb_md;

  mrb_md = (struct mrb_matchdata *)DATA_PTR(self);
  if (mrb_md) {
    mrb_matchdata_free(mrb, mrb_md);
  }
  DATA_TYPE(self) = &mrb_matchdata_type;
  DATA_PTR(self) = NULL;

  mrb_md = (struct mrb_matchdata *)mrb_malloc(mrb, sizeof(*mrb_md));
  mrb_md->ovector = NULL;
  mrb_md->length = -1;
  DATA_PTR(self) = mrb_md;

  return self;
}

mrb_value
mrb_matchdata_init_copy(mrb_state *mrb, mrb_value copy)
{
  mrb_value src;
  struct mrb_matchdata *mrb_md_copy, *mrb_md_src;
  int vecsize;

  mrb_get_args(mrb, "o", &src);

  if (mrb_obj_equal(mrb, copy, src)) return copy;
  if (!mrb_obj_is_instance_of(mrb, src, mrb_obj_class(mrb, copy))) {
    mrb_raise(mrb, E_TYPE_ERROR, "wrong argument class");
  }

  mrb_md_copy = (struct mrb_matchdata *)mrb_malloc(mrb, sizeof(*mrb_md_copy));
  mrb_md_src  = DATA_PTR(src);

  if (mrb_md_src->ovector == NULL) {
    mrb_md_copy->ovector = NULL;
    mrb_md_copy->length = -1;
  } else {
    vecsize = sizeof(int) * mrb_md_src->length * 3;
    mrb_md_copy->ovector = mrb_malloc(mrb, vecsize);
    memcpy(mrb_md_copy->ovector, mrb_md_src->ovector, vecsize);
    mrb_md_copy->length = mrb_md_src->length;
  }

  if (DATA_PTR(copy) != NULL) {
    mrb_matchdata_free(mrb, DATA_PTR(copy));
  }
  DATA_PTR(copy) = mrb_md_copy;

  mrb_iv_set(mrb, copy, mrb_intern_lit(mrb, "@regexp"), mrb_iv_get(mrb, src, mrb_intern_lit(mrb, "@regexp")));
  mrb_iv_set(mrb, copy, mrb_intern_lit(mrb, "@string"), mrb_iv_get(mrb, src, mrb_intern_lit(mrb, "@string")));

  return copy;
}

static mrb_value
matchdata_beginend(mrb_state *mrb, mrb_value self, int beginend)
{
  struct mrb_matchdata *mrb_md;
  mrb_int i, offs;

  mrb_md = (struct mrb_matchdata *)mrb_get_datatype(mrb, self, &mrb_matchdata_type);
  if (!mrb_md) return mrb_nil_value();

  mrb_get_args(mrb, "i", &i);
  if (i < 0 || i >= mrb_md->length)
    mrb_raisef(mrb, E_INDEX_ERROR, "index %d out of matches", i);

  offs = mrb_md->ovector[i*2 + beginend];
  if (offs != -1)
    return mrb_fixnum_value(offs);
  else
    return mrb_nil_value();
}

mrb_value
mrb_matchdata_begin(mrb_state *mrb, mrb_value self)
{
  return matchdata_beginend(mrb, self, 0);
}

mrb_value
mrb_matchdata_end(mrb_state *mrb, mrb_value self)
{
  return matchdata_beginend(mrb, self, 1);
}

mrb_value
mrb_matchdata_length(mrb_state *mrb, mrb_value self)
{
  struct mrb_matchdata *mrb_md;

  mrb_md = (struct mrb_matchdata *)mrb_get_datatype(mrb, self, &mrb_matchdata_type);
  if (!mrb_md) return mrb_nil_value();

  return mrb_fixnum_value(mrb_md->length);
}

void
mrb_mruby_regexp_pcre_gem_init(mrb_state *mrb)
{
  struct RClass *re, *md;

  re = mrb_define_class(mrb, "Regexp", mrb->object_class);
  MRB_SET_INSTANCE_TT(re, MRB_TT_DATA);

  mrb_define_method(mrb, re, "initialize", regexp_pcre_initialize, MRB_ARGS_REQ(1) | MRB_ARGS_OPT(2));
  mrb_define_method(mrb, re, "match", regexp_pcre_match, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, re, "==", regexp_equal, MRB_ARGS_REQ(1));

  mrb_define_const(mrb, re, "IGNORECASE", mrb_fixnum_value(MRUBY_REGEXP_IGNORECASE));
  mrb_define_const(mrb, re, "EXTENDED", mrb_fixnum_value(MRUBY_REGEXP_EXTENDED));
  mrb_define_const(mrb, re, "MULTILINE", mrb_fixnum_value(MRUBY_REGEXP_MULTILINE));

  md = mrb_define_class(mrb, "MatchData", mrb->object_class);
  MRB_SET_INSTANCE_TT(md, MRB_TT_DATA);

  mrb_define_method(mrb, md, "initialize", mrb_matchdata_init, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, md, "initialize_copy", mrb_matchdata_init_copy, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, md, "begin", mrb_matchdata_begin, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, md, "end", mrb_matchdata_end, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, md, "length", mrb_matchdata_length, MRB_ARGS_NONE());
}

void
mrb_mruby_regexp_pcre_gem_final(mrb_state *mrb)
{
}
