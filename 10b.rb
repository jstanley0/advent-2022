require_relative 'skim'

timings = {}
x = 1
t = 0
ARGF.each do |line|
  case line
  when /noop/
    t += 1
  when /addx (.+)/
    t += 2
    x += $1.to_i
    timings[t] = x
  end
end

pic = Skim.new(40, 6, '.')
x = 1
t = 0
6.times do |row|
  40.times do |col|
    x = timings[t] if timings.key?(t)
    pic[col, row] = '#' if col.between?(x-1, x+1)
    t += 1
  end
end
pic.print
