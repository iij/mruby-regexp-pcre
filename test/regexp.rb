assert('Regexp', '15.2.15.1') do
  Regexp.class == Class and
  Regexp.superclass == Object
end

assert('Regexp.compile', '15.2.15.6.1') do
  re = Regexp.new('abc')
  re.class == Regexp
end

assert('Regexp.escape', '15.2.15.6.2') do
  # simply test
  re1 = Regexp.escape("$bc^")
  # PENDING: \n \t \r \f 0x20
  #re2 = Regexp.escape("0x0a 0x09 0x0d 0x0c 0x20")
  # '#' '$' '(' ')' '*' '+' '-'
  re3 = Regexp.escape("#$()*+-")
  # '.' '?' '[' ']' '^' '{' '|' '}'
  re4 = Regexp.escape(".?[]^{|}")
  # '\'
  re5 = Regexp.escape('\\')

  re1 == '\$bc\^' and
  # re2 == "\n\t\r\f" + "\ 0x20" and
  re3 == '\#\$\(\)\*\+\-' and
  re4 == '\.\?\[\]\^\{\|\}' and
  re5 == '\\\\'
end

assert('Regexp.last_match', '15.2.15.6.3') do
  re = Regexp.compile("(.)(.)")
  re.match("ab")

  Regexp.last_match.class == MatchData and
  Regexp.last_match[0] == "ab" and
  Regexp.last_match[1] == "a" and
  Regexp.last_match[2] == "b" and
  Regexp.last_match[3] == nil
end

assert('Regexp.quote', '15.2.15.6.4') do
  # simply test
  re1 = Regexp.quote("$bc^")
  # PENDING: \n \t \r \f 0x20
  #re2 = Regexp.escape("0x0a 0x09 0x0d 0x0c 0x20")
 
  # '#' '$' '(' ')' '*' '+' '-'
  re3 = Regexp.quote("#$()*+-")
  # '.' '?' '[' ']' '^' '{' '|' '}'
  re4 = Regexp.quote(".?[]^{|}")
  # '\'
  re5 = Regexp.quote('\\')

  # re2 == "\n\t\r\f" + "\ 0x20" and

  re1 == '\$bc\^' and
  re3 == '\#\$\(\)\*\+\-' and
  re4 == '\.\?\[\]\^\{\|\}' and
  re5 == '\\\\'
end

assert('Regexp#==', '15.2.15.7.1') do
  a = Regexp.compile("abcd")
  b = Regexp.compile("abcd")
  c = Regexp.compile("c")

  (a == b) == true and
  (a == c) == false and
  (b == c) == false
end

assert('Regexp#===', '15.2.15.7.2') do
  a = "HELLO"
  b = "hello"
  re = Regexp.compile("^[A-Z]*$")

  (re === a) == true and
  (re === b) == false
end

assert('Regexp#=~', '15.2.15.7.3') do
  re = Regexp.compile("foo")
  (re =~ "foo") == 0 and
  (re =~ "afoo") == 1 and
  (re =~ "bar") == nil
end

assert('Regexp#casefold?', '15.2.15.7.4') do
  a = Regexp.compile("foobar", Regexp::IGNORECASE)
  b = Regexp.compile("hogehoge")

  a.casefold? == true and
  b.casefold? == false
end

#assert('Regexp#initialize', '15.2.15.7.5') do
#end

#assert('Regexp#initialize_copy', '15.2.15.7.6') do
#end

assert('Regexp#match', '15.2.15.7.7') do
  re = Regexp.compile("(.)(.)")
  m = re.match("afoo")

  m.class == MatchData and
  m.to_s == "af" and
  m[1] == "a" and
  m[2] == "f"
end

assert('Regexp#options (literal)') do
  re1 = /aaa/
  re2 = /aaa/i
  re3 = /aaa/x
  re4 = /aaa/m

  re1.options == 0 and
  re2.options == 1 and
  re3.options == 2 and
  re4.options == 4
end

assert('Regexp#options') do
  re1 = Regexp.compile("aaa")
  re2 = Regexp.compile("aaa", Regexp::IGNORECASE)
  re3 = Regexp.compile("aaa", Regexp::EXTENDED)
  re4 = Regexp.compile("aaa", Regexp::MULTILINE)

  re1.options == 0 and
  re2.options == 1 and
  re3.options == 2 and
  re4.options == 4
end

assert('Regexp#source') do
  //.source == "" and
  /foo|bar|baz/i.source == "foo|bar|baz" and
  /.?a*b+(c)[^d]/.source == ".?a*b+(c)[^d]"
end

assert('Regexp#to_s') do
  /foo|bar|baz/i.to_s == "(?i-mx:foo|bar|baz)" and
  /a. b/mx.to_s == "(?mx-i:a. b)"
end

assert('Regexp Literal (1)') do
  re1 = /aaa/
  re2 = Regexp.compile("aaa")
  re3 = /aaa/i
  re4 = Regexp.compile("aaa", Regexp::IGNORECASE)

  unless re1 == re2
    p re1, re2
  end
  unless re3 == re4
    p re3, re4
  end

  re1 == re2 and
  re3 == re4
end

assert('Regexp Literal (2)') do
  re1 = /a\nb/
  re2 = /a\\nb/
  re3 = /a\/b/
  re4 = /a"b/

  re1.source == "a\\nb" and
  re2.source == "a\\\\nb" and
  re3.source == "a/b"   and
  re4.source == 'a"b'
end

assert('Regexp Literal (3)') do
  re1 = /a\sb/
  re2 = /a\tb/
  re3 = /a\:b/
  re4 = /a\?b/

  if false
  puts
  puts re1, re1.source, re1.source == "a\\sb"
  puts re2, re2.source, re2.source == "a\\tb"
  puts re3, re3.source, re3.source == "a\\:b"
  puts re4, re4.source, re4.source == "a\\?b"
  end

  re1.source == "a\\sb" and
  re2.source == "a\\tb" and
  re3.source == "a\\:b"   and
  re4.source == 'a\\?b'
end

assert('Regexp Literal (4)') do
  re1 = /\A\w\W\s\S\D\b\B\Z/
  str = "\\A\\w\\W\\s\\S\\D\\b\\B\\Z"
  re2 = Regexp.compile(str)

  re1.source == str and
  re1 == re2
end

assert('Regexp Literal (5): escape charactor') do
  (/a\nb/ =~ "a\nb") == 0 and
  (/a
b/ =~ "a\nb") == 0 and
  (%r!a\tb! =~ "a\tb") == 0 and
  (%r!a\\tb! =~ "a\\tb") == 0
end

assert('Regexp Literal (6): matching test') do
  (/^foo$/ =~ "foo") == 0 and # ^ and $
  (/(\w)(\W)/ =~ "this is test!") == 3 and Regexp.last_match[1] == "s" and
  (/\s/ =~ "this is test") == 4 and
  (/\S/ =~ "this is test") == 0 and
  (/\d/ =~ "abc123") == 3 and
  (/\D/ =~ "abc123") == 0 and
  (/\Aabc(.*)\Z/m =~ "abc\ntest") == 0 and Regexp.last_match[1] == "\ntest" and
  # missing \z
  # missing \b, \B
  # missing \G
  (/[a-z]/ =~ "0123abc") == 4 and 
  (/(a.*)/ =~ "bbbaaa") == 3 and Regexp.last_match[1] == "aaa" and
  (/(a.*?)/ =~ "bbbaaa") == 3 and Regexp.last_match[1] == "a" and
  (/(a+)/ =~ "bbbaaa") == 3 and Regexp.last_match[1] == "aaa" and
  (/(a+?)/ =~ "bbbaaa") == 3 and Regexp.last_match[1] == "a" and
  (/(foo){1,}/ =~ "barfoofoofoofoo") == 3 and Regexp.last_match[0] == "foofoofoofoo" and
  (/(foo){1,}?/ =~ "barfoofoofoofoo") == 3 and Regexp.last_match[0] == "foo" and
  (/(\d.?)/ =~ "abc0123") == 3 and Regexp.last_match[1] == "01" and
  (/(\d.??)/ =~ "abc0123") == 3 and Regexp.last_match[1] == "0" and
  (/hoge|fuga/ =~ "hoge") == 0 and
  (/(.)/ =~ "abcdef") == 0 and Regexp.last_match[0] == "a" and
  (/(?#comment)test/ =~ "test") == 0 and
  (/(?:abc)/ =~ "abc") == 0 and Regexp.last_match[1] == nil and
  (/((?=\d{2,4}3)\d{8})/ =~ "asdf1234567890") == 4 and
  (/(?!000)\d\d\d/ =~ "0001234") == 1 and
  (/(?<=\d)/ =~ "abc123def") == 4 and
  (/(?<!foo)bar/ =~ 'foobarbazbarfoo') == 9 and
  (/A(?i)a(?-i)A/ =~ "AaA") == 0 and
  (/A(?i:a)A/ =~ "AaA") == 0
end

assert('Regexp option "i"', '15.2.15.1') do
  (/abcdef/i =~ "ABCDEF") == 0 and
  (/abcdef/i =~ "AAAAAA") == nil
end

assert('Regexp option "m"', '15.2.15.1') do
  msg = "Random Line 1\n"
  msg += "Random Line 2\n"
  msg += "From: person@example.com\n"
  msg += "Subject: This is the subject line\n"

  (/(From:.*Subject.*?)/m =~ msg) != nil
end

assert('Regexp option "x"', '15.2.15.1') do
  (/foo # comment
  bar/x =~ "foobar") == 0 and
  (/foo # comment
  bar/x =~ "foo\nbar") == nil
end
