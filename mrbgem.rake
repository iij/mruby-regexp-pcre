MRuby::Gem::Specification.new('mruby-regexp-pcre') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Internet Initiative Japan Inc.'

  spec.linker.libraries << ['pcre']
end
