assert('MatchData', '15.2.16.2') do
  MatchData.class == Class and
  MatchData.superclass == Object
end

assert('MatchData#[]', '15.2.16.3.1') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m[0] == "foobar" and m[1] == "foo" and m[2] == "bar" and m[3] == nil and
  m[4] == nil and m[-2] == "bar"
end

assert('MatchData#begin', '15.2.16.3.2') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.begin(0) == 0 and m.begin(1) == 0 and m.begin(2) == 3 and m.begin(3) == nil
end

assert('MatchData#captures', '15.2.16.3.3') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.captures == ["foo", "bar", nil]
end

assert('MatchData#end', '15.2.16.3.4') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.end(0) == 6 and m.end(1) == 3 and m.end(2) == 6 and m.end(3) == nil
end

assert('MatchData#initialize_copy', '15.2.16.3.5') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  n = /a/.match("a").initialize_copy(m)
  m.to_a == n.to_a and m.regexp == n.regexp and m.string == n.string
end

assert('MatchData#length', '15.2.16.3.6') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.length == 4
end

assert('MatchData#offset', '15.2.16.3.7') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.offset(1) == [0, 3] and m.offset(2) == [3, 6] and m.offset(3) == [nil, nil]
end

assert('MatchData#post_match', '15.2.16.3.8') do
  m = /(bar)(BAZ)?/.match("foobarbaz")
  m.post_match == "baz"
end

assert('MatchData#pre_match', '15.2.16.3.9') do
  m = /(bar)(BAZ)?/.match("foobarbaz")
  m.pre_match == "foo"
end

assert('MatchData#size', '15.2.16.3.10') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.size == m.length
end

assert('MatchData#string', '15.2.16.3.11') do
  m = /b/.match("abc", 1)
  m.string == "abc"
end

assert('MatchData#to_a', '15.2.16.3.12') do
  m = /(foo)(bar)(BAZ)?/.match("foobarbaz")
  m.to_a == ["foobar", "foo", "bar", nil]
end

assert('MatchData#to_a', '15.2.16.3.13') do
  m = /bar/.match("foobarbaz")
  m.to_s == "bar"
end

assert('MatchData#names') do
  m = /(?<foo>.)(?<bar>.)(?<baz>.)/.match("hoge")
  m.names == ["foo", "bar", "baz"]
end

assert('MatchData#regexp') do
  m = /a.*b/.match("abc")
  m.regexp == /a.*b/
end

assert('MatchData#values_at') do
  m = /(foo)(bar)(baz)/.match("foobarbaz")
  m.values_at(0, 1, 2, 3, 4) == ["foobarbaz", "foo", "bar", "baz", nil] and
  m.values_at(-1, -2, -3, -4, -5) == ["baz", "bar", "foo", nil, nil]
end
