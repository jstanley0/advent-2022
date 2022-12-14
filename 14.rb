require_relative 'skim'

splines = ARGF.map do |line|
  line.scan(/\d+,\d+/).map{_1.split(',').map(&:to_i)}
end
flat_coords = splines.flatten(1)
min_y = 0
max_y = flat_coords.map{_1[1]}.max
min_x, max_x = flat_coords.map{_1[0]}.minmax

w = max_x - min_x + 1
h = max_y - min_y + 1
puts "#{w}x#{h}"

mapp = Skim.new(w, h, '.')
splines.each do |spline|
  spline.each_cons(2) do |c0, c1|
    if c0[0] == c1[0]
      # vertical
      (c0[1]..c1[1]).step(c1[1] <=> c0[1]).each do |y|
        mapp[c0[0] - min_x, y - min_y] = '#'
      end
    elsif c0[1] == c1[1]
      # horizontal
      (c0[0]..c1[0]).step(c1[0] <=> c0[0]).each do |x|
        mapp[x - min_x, c0[1] - min_y] = '#'
      end
    else
      raise "diagonal line segment??"
    end
  end
end

def add_sand(mapp, x)
  y = 0
  loop do
    # fall down
    while mapp.in_bounds?(x, y) && mapp[x, y] == '.'
      y += 1
    end
    # if we fell into the abyss, we're done
    return false unless mapp.in_bounds?(x, y)

    # see if we can fall diagonally to the left or right
    if !mapp.in_bounds?(x - 1, y) || mapp[x - 1, y] == '.'
      x -= 1
    elsif !mapp.in_bounds?(x + 1, y) || mapp[x + 1, y] == '.'
      x += 1
    else
      # can't fall; come to rest here
      mapp[x, y - 1] = 'o'
      return true
    end
  end
end

sand = 0
sand += 1 while add_sand(mapp, 500 - min_x)

mapp.print
puts sand
