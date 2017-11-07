mruby-regexp-pcre
=================

"mruby-regexp-pcre" is a regular expression module for mruby, based on
[PCRE](http://pcre.org).
It provides Regexp and MatchData classes.


## Requirements

none (libpcre is bundled).


## Example

```Ruby
line = "#hoge"
/^#.*/ =~ line

csv = "a, b, c"
csv.split /,\s*/

kvs = "key: value"
m = /(\w+)\s*:\s*(\w*)/.match(kvs)
key, value = m[1], m[2]
```

## Test
If you have mruby source code and imported mruby-regexp-pcre as an mrbgem,
just run "rake test" to execute test scripts in ``test`` directory:
```
% cd mruby
% rake test
```

Or run ``run_test.rb`` to check out mruby source code into a temporary directory,
and run tests on it:
```
% cd mruby-regexp-pcre
% ruby run_test.rb test
% rm -rf tmp
```

## Alternatives
If mruby-regexp-pcre does not meet your requirements, try mruby-onig-regexp.
It consumes much more memory but has better compatibility with MRI.

- https://github.com/mattn/mruby-onig-regexp (Onigumo/Oniguruma)

Other alternatives:

- https://github.com/mattn/mruby-pcre-regexp (PCRE)
- https://github.com/masamitsu-murase/mruby-hs-regexp (Henry Spencer's)


## License

Copyright (c) 2013 Internet Initiative Japan Inc.

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
