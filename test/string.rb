# TODO: SEGFAULT ATM assert('String#=~', '15.2.10.5.5')

assert('String#[]', '15.2.10.5.6') do

  # args is RegExp
  # TODO SEGFAULT ATM

  true
end

assert('String#gsub with Regexp', '15.2.10.5.18') do
  assert_raise(ArgumentError) do
    "abc".gsub()
  end

  # Despite violation ISO Ruby 15.2.10.5.18 (a), MRI does not raise an
  # ArgumentError.
  #assert_raise(ArgumentError) do
  #  "abc".gsub("a")
  #end

  assert_raise(ArgumentError) do
    "abc".gsub("a", "x", "0")
  end

  re = Regexp.compile('def')
  assert_equal "abc!!g", 'abcdefg'.gsub(re, '!!')

  re = Regexp.compile('b')
  assert_equal "a<<b>>ca<<b>>c", 'abcabc'.gsub(re, '<<\&>>')

  re = Regexp.compile('x+(b+)')
  assert_equal "X<<bb>>X<<bb>>", 'xxbbxbb'.gsub(re, 'X<<\1>>')

  assert_equal "2,5", '2.5'.gsub('.', ',')
end

assert('String#gsub! with Regexp', '15.2.10.5.19') do
  result1 = "String-String"
  re = Regexp.compile('in.')
  result1.gsub!(re, "!!")

  result2 = "String-String"
  re = Regexp.compile('in.')
  result2.gsub!(re, '<<\&>>')

  result1 == "Str!!-Str!!" and
  result2 == "Str<<ing>>-Str<<ing>>"
end

assert('String#gsub', '15.2.10.5.18') do
  'abcabc'.gsub('b', 'B') == 'aBcaBc' && 'abcabc'.gsub('b') { |w| w.capitalize } == 'aBcaBc' 
end

assert('String#gsub!', '15.2.10.5.19') do
  a = 'abcabc'
  a.gsub!('b', 'B')

  b = 'abcabc'
  b.gsub!('b') { |w| w.capitalize }

  a == 'aBcaBc' && b == 'aBcaBc' 
end

assert('String#gsub regression #13') do
  assert_equal "abc",  "abc".gsub(/^\s*/, "")
  assert_equal "xaxxcx", "abc".gsub(/b?/, "x")
end

assert('String#index') do
  assert_equal 0,   'abc'.index(/a/)
  assert_equal nil, 'abc'.index(/d/)
  assert_equal 3,   'abcabc'.index(/a/, 1)
  assert_equal 4,   'abcabc'.index(/b/, -4)
end

# TODO Broken ATM assert('String#match', '15.2.10.5.27') do

assert('String#rindex', '15.2.10.5.31') do
  'abc'.rindex('a') == 0 and 'abc'.rindex('d') == nil and
    'abcabc'.rindex('a', 1) == 0 and 'abcabc'.rindex('a', 4) == 3
end

assert('String#scan', '15.2.10.5.32') do
  re = Regexp.compile('..')
  result1 = "foobar".scan(re)
  re = Regexp.compile('ba.')
  result2 = "foobarbazfoobarbazz".scan(re)
  re = Regexp.compile('(.)')
  result3 = "foobar".scan(re)
  re = Regexp.compile('(ba)(.)')
  result4 = "foobarbazfoobarbaz".scan(re)

  result1 == ["fo", "ob", "ar"] and
  result2 == ["bar", "baz", "bar", "baz"] and
  result3 == [["f"], ["o"], ["o"], ["b"], ["a"], ["r"]] and
  result4 == [["ba", "r"], ["ba", "z"], ["ba", "r"], ["ba", "z"]]
end

assert('String#slice', '15.2.10.5.34') do
  # length of args is 1
  a = 'abc'.slice(0)
  b = 'abc'.slice(-1)
  c = 'abc'.slice(10)
  d = 'abc'.slice(-10)

  # length of args is 2
  a1 = 'abc'.slice(0, -1)
  b1 = 'abc'.slice(10, 0)
  c1 = 'abc'.slice(-10, 0)
  d1 = 'abc'.slice(0, 0)
  e1 = 'abc'.slice(1, 2)

  # slice of shared string
  e11 = e1.slice(0)

  # args is RegExp
  # TODO SEGFAULT ATM

  # args is String
  a3 = 'abc'.slice('bc')
  b3 = 'abc'.slice('XX')

  a == 'a' and b == 'c' and c == nil and d == nil and
    a1 == nil and b1 == nil and c1 == nil and d1 == '' and
    e1 == 'bc' and e11 == 'b' and
    a3 == 'bc' and b3 == nil
end

assert('String#slice!') do
  x1 = 'abc'
  x2 = x1.clone
  x3 = x1.clone
  y1 = x1.slice!(0)
  y2 = x2.slice!(1)
  y3 = x3.slice!(-1)

  u1 = 'abc'
  u2 = u1.clone
  u3 = u1.clone
  v1 = u1.slice!(0, 0)
  v2 = u2.slice!(0, 1)
  v3 = u3.slice!(0, -1)

  x1 == 'bc' and x2 == 'ac' and x3 == 'ab' and
    y1 == 'a' and y2 == 'b' and y3 == 'c' and
    u1 == 'abc' and u2 == 'bc' and u3 == 'abc' and
    v1 == '' and v2 == 'a' and v3 == nil
end

assert('String#split', '15.2.10.5.35') do
  ''.split(//)               == []                          and
  ''.split(/x/)              == []                          and
  'abc'.split(//)            == ['a', 'b', 'c']             and
  'abc'.split(/,/)           == ['abc']                     and
  'a1b23c45'.split(/\d/)     == ['a', 'b', '', 'c']         and
  'a1b23c45'.split(/\d/, 0)  == ['a', 'b', '', 'c']         and
  'a1b23c45'.split(/\d/, 1)  == ['a1b23c45']                and
  'a1b23c45'.split(/\d/, 4)  == ['a', 'b', '', 'c45']       and
  'a1b23c45'.split(/\d/, -4) == ['a', 'b', '', 'c', '', ''] and
  'abc'.split(//, 2)         == ['a', 'bc']                 and
  'a bc'.split(/\s*/)        == ['a', 'b', 'c']             and
  ' abc  abc abc'.split(/ /) == ['', 'abc', '', 'abc', 'abc'] and
  '1, 2.34,56, 7'.split(/,\s*/) == ['1', '2.34', '56', '7']
end

# TODO ATM broken assert('String#sub', '15.2.10.5.36') do
assert('String#sub with Regexp', '15.2.10.5.36') do
  re = Regexp.compile('def')
  result1 = 'abcdefg'.sub(re, '!!')
  re = Regexp.compile('b')
  result2 = 'abcabc'.sub(re, '<<\&>>')
  re = Regexp.compile('x+(b+)')
  result3 = 'xbbxbb'.sub(re, 'X<<\1>>')
  re = Regexp.compile('foo')
  result4 = 'bar'.sub(re, 'zee')

  result1 == "abc!!g" and
  result2 == "a<<b>>cabc" and
  result3 == "X<<bb>>xbb" and
  result4 == 'bar'
end

# TODO ATM broken assert('String#sub!', '15.2.10.5.37') do
assert('String#sub! with Regexp', '15.2.10.5.37') do
  result1 = "String-String"
  re = Regexp.compile('in.')
  result1.sub!(re, "!!")

  result2 = "String-String"
  re = Regexp.compile('in.')
  result2.sub!(re, '<<\&>>')

  result3 = 'bar'
  re = Regexp.compile('foo')
  result3.sub!(re, 'zee')

  result1 == "Str!!-String" and
  result2 == "Str<<ing>>-String" and
  result3 == 'bar'
end

assert('String#sub', '15.2.10.5.36') do
  'abcabc'.sub('b', 'B') == 'aBcabc' && 'abcabc'.sub('b') { |w| w.capitalize } == 'aBcabc' 
end

assert('String#sub!', '15.2.10.5.37') do
  a = 'abcabc'
  a.sub!('b', 'B')

  b = 'abcabc'
  b.sub!('b') { |w| w.capitalize }

  a == 'aBcabc' && b == 'aBcabc'
end
