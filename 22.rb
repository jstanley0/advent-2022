require_relative 'skim'

mapp = Skim.read(rec: false).rectangularize(' ')
mapp.print
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

dirs.scan(/\d+|L|R/).each do |dir|
  #puts dir
  case dir
  when 'L'
    a = (a - 1) % 4
  when 'R'
    a = (a + 1) % 4
  else
    dist = dir.to_i
    dist.times do
      ty = (y + DIRS[a][1]) % mapp.height
      tx = (x + DIRS[a][0]) % mapp.width
      while mapp[tx, ty] == ' '
        ty = (ty + DIRS[a][1]) % mapp.height
        tx = (tx + DIRS[a][0]) % mapp.width
      end

      break if mapp[tx, ty] == '#'
      traced[x, y] = MARKS[a]
      x, y = tx, ty
    end
  end
  traced[x, y] = MARKS[a]
  #traced.print
end

puts "x=#{x}, y=#{y}, a=#{a}  ans=#{1000*(y+1)+4*(x+1)+a}"
