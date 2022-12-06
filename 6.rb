def find_distinct(line, n)
  line.chars.each_cons(n).find_index { _1.uniq.size == _1.size } + n
end

line = ARGF.gets
p find_distinct(line, 4)
p find_distinct(line, 14)
