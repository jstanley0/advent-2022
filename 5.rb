require_relative 'skim'

stacks = []
pic = Skim.read
y1 = pic.height - 1
(0...pic.width).each do |x|
  if pic[x,y1] != ' '
    y = y1 - 1
    stack = []
    while y >= 0
      if pic[x,y] != ' '
        stack << pic[x,y]
      else
        break
      end
      y -= 1
    end
    stacks << stack
  end
end
steps = ARGF.readlines

st = stacks.map(&:dup)
steps.each do |line|
  break unless line =~ /move (\d+) from (\d+) to (\d+)/
  $1.to_i.times do
    letter = st[$2.to_i - 1].pop
    st[$3.to_i - 1].push letter
  end
end
puts st.map(&:last).join

st = stacks.map(&:dup)
steps.each do |line|
  break unless line =~ /move (\d+) from (\d+) to (\d+)/
  substack = st[$2.to_i - 1].pop($1.to_i)
  st[$3.to_i - 1].concat substack
end
puts st.map(&:last).join
