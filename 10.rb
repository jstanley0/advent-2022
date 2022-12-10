x = 1
t = 1
target = 20
ss = 0
ARGF.each do |line|
  t0 = t
  x0 = x
  case line
  when /noop/
    t += 1
  when /addx (.+)/
    t += 2
    x += $1.to_i
  end
  if t0 < target && t >= target
    xm = t > target ? x0 : x
    puts "target=#{target} t=#{t} x=#{xm} xt=#{xm * target}"
    ss += xm * target
    target += 40
  end
end
puts "--"
puts ss
