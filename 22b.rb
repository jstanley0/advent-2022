require_relative 'skim'

mapp = Skim.read(rec: false).rectangularize(' ')
traced = mapp.dup
dirs = ARGF.gets

DIRS = [
  [1, 0],  # right
  [0, 1],  # down
  [-1, 0], # left
  [0, -1]  # up
]

MARKS = %w[> v < ^]

y = 0
x = mapp.data[0].find_index{_1 != ' '}
a = 0

# this is not at all generalized, sry. won't even work on the example
def wrap_around_cube(x, y, a)
  qx, rx = x.divmod 50
  qy, ry = y.divmod 50
  case [qx, qy]
  when [1, 0]
    case a
    when 2 then [0, 149 - ry, 0]
    when 3 then [0, 150 + rx, 0]
    else
      raise "nuts!"
    end
  when [2, 0]
    case a
    when 0 then [99, 149 - ry, 2]
    when 1 then [99, 50 + rx, 2]
    when 3 then [rx, 199, 3]
    else
      raise "zounds"
    end
  when [1, 1]
    case a
    when 0 then [100 + ry, 49, 3]
    when 2 then [ry, 100, 1]
    else
      raise "oook"
    end
  when [0, 2]
    case a
    when 2 then [50, 49 - ry, 0]
    when 3 then [50, 50 + rx, 0]
    else
      raise "crap"
    end
  when [1, 2]
    case a
    when 0 then [149, 49 - ry, 2]
    when 1 then [49, 150 + rx, 2]
    else
      raise ":("
    end
  when [0, 3]
    case a
    when 0 then [50 + ry, 149, 3]
    when 1 then [100 + rx, 0, 1]
    when 2 then [50 + ry, 0, 1]
    else
      raise "foo"
    end
  else
    puts "!! #{x}, #{y}, #{a} #{MARKS[a]}"
    raise "whoops"
  end
end

dirs.scan(/\d+|L|R/).each do |dir|
  print dir + ": "
  case dir
  when 'L'
    a = (a - 1) % 4
  when 'R'
    a = (a + 1) % 4
  else
    dist = dir.to_i
    dist.times do
      a0 = a
      dx, dy = DIRS[a]
      if !mapp.in_bounds?(x + dx, y + dy) || mapp[x + dx, y + dy] == ' '
        tx, ty, a = wrap_around_cube(x, y, a)
      else
        tx, ty = x + dx, y + dy
      end

      if mapp[tx, ty] == '#'
        a = a0
        break
      end
      traced[x, y] = MARKS[a0]
      x, y = tx, ty
    end
  end
  traced[x, y] = MARKS[a]
  #traced.print
  puts "#{x}, #{y}, #{a} #{MARKS[a]}"
end

puts "x=#{x}, y=#{y}, a=#{a}  ans=#{1000*(y+1)+4*(x+1)+a}"
