def pri(c)
  case c
  when 'A'..'Z'
    (c.ord - 'A'.ord) + 27
  when 'a'..'z'
    (c.ord - 'a'.ord) + 1
  end
end

puts ARGF.map { |line|
  line.strip!
  r0 = line[0...line.size/2]
  r1 = line[line.size/2..]
  c = r0.chars.detect { r1.chars.include? _1 }
  pri(c)
}.sum
