MRuby::Gem::Specification.new('mruby-regexp-pcre') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Internet Initiative Japan Inc.'

  spec.linker.libraries << ['pcre']

  ## For static link library
  # How to use:
  #  * download pcre library
  #    $ pwd
  #    $(mruby.rootdir)/mrbgems/mruby-regexp-pcre
  #    $ wget http://xxxxx/xxxxx/pcre-X.XX.tar.gz
  #
  #  * unpack, setup path
  #    $ tar zxf pcre-X.XX.tar.gz
  #    $ mv pcre-X.XX pcre
  #    $ vim ./mrbgem.rake
  #    (edit pcre_dirname variable)
  #
  #  * move the mruby root dir, make
  #    $ cd $(mruby.rootdir)
  #    $ make

  #pcre_dirname = 'pcre'
  #pcre_src = "#{spec.dir}/#{pcre_dirname}"
  #spec.cc.include_paths << "#{pcre_src}"
  #spec.cc.flags << '-DHAVE_CONFIG_H'

  #FileUtils.cp("#{pcre_src}/config.h.generic", "#{pcre_src}/config.h") unless File.exists?("#{pcre_src}/config.h")
  #FileUtils.cp("#{pcre_src}/pcre.h.generic", "#{pcre_src}/pcre.h") unless File.exists?("#{pcre_src}/pcre.h")
  #FileUtils.cp("#{pcre_src}/pcre_chartables.c.dist", "#{pcre_src}/pcre_chartables.c") unless File.exists?("#{pcre_src}/pcre_chartables.c")

  #spec.objs += %W(
  #  #{pcre_src}/pcre_byte_order.c
  #  #{pcre_src}/pcre_compile.c
  #  #{pcre_src}/pcre_config.c
  #  #{pcre_src}/pcre_dfa_exec.c
  #  #{pcre_src}/pcre_exec.c
  #  #{pcre_src}/pcre_fullinfo.c
  #  #{pcre_src}/pcre_get.c
  #  #{pcre_src}/pcre_globals.c
  #  #{pcre_src}/pcre_jit_compile.c
  #  #{pcre_src}/pcre_maketables.c
  #  #{pcre_src}/pcre_newline.c
  #  #{pcre_src}/pcre_ord2utf8.c
  #  #{pcre_src}/pcre_refcount.c
  #  #{pcre_src}/pcre_string_utils.c
  #  #{pcre_src}/pcre_study.c
  #  #{pcre_src}/pcre_tables.c
  #  #{pcre_src}/pcre_ucd.c
  #  #{pcre_src}/pcre_valid_utf8.c
  #  #{pcre_src}/pcre_version.c
  #  #{pcre_src}/pcre_xclass.c
  #  #{pcre_src}/pcre_chartables.c
  #).map { |f| f.relative_path_from(dir).pathmap("#{build_dir}/%X.o") }
end
