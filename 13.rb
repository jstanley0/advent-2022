# -1 = no; 1 = yes; 0 = indeterminate (keep looking)
def ordered?(a, b)
  return b <=> a if a.is_a?(Integer) && b.is_a?(Integer)
  return ordered?(Array(a), Array(b)) if a.is_a?(Integer) || b.is_a?(Integer)

  # both are arrays
  a.size.times do |i|
    return -1 if i >= b.size
    o = ordered?(a[i], b[i])
    return o if o != 0
  end

  b.size > a.size ? 1 : 0
end

pears = ARGF.read.split("\n\n").map{|p|p.split.map{eval _1}}
sum = 0
pears.each_with_index do |(a, b), i|
  o = ordered?(a, b) == 1
  puts "#{i + 1}: #{o}"
  sum += (i + 1) if o
end
puts "--"
puts sum

packets = pears.flatten(1).push([[2]], [[6]]).sort { -ordered?(_1, _2) }
puts packets.inspect
puts (packets.index([[2]]) + 1) * (packets.index([[6]]) + 1)
