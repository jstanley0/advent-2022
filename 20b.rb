data = ARGF.readlines.map(&:to_i)
data = data.each_with_index.map { |n, i| [n * 811589153, i] }

10.times do
  data.size.times do |n|
    i = data.find_index {_2 == n}
    v = data.delete_at(i)
    data.insert((i + v[0]) % data.size, v)
  end
end

i = data.find_index { _1[0] == 0 }
x = data[(i + 1000) % data.size][0]
y = data[(i + 2000) % data.size][0]
z = data[(i + 3000) % data.size][0]
p x, y, z, x+y+z
