require 'set'
require_relative 'skim'

data = $<.map{_1.split(?,).map(&:to_i)}

def surface_area(cubes)
  6 * cubes.size - 2 * cubes.combination(2).count{|a,b|a.zip(b).sum{(_2-_1).abs}==1}
end

sz = data.flatten.max + 3
space = sz.times.map { Skim.new(sz, sz, '.') }
data.each do |x, y, z|
  space[z + 1][x + 1, y + 1] = '#'
end

# fill with steam
queue = Set.new([[0, 0, 0]])
until queue.empty?
  x, y, z = queue.first.tap { queue.delete(_1) }
  space[z][x, y] = 'S'
  space[z].nabes(x, y, diag: false) do |v, a, b|
    queue << [a, b, z] if v == '.'
  end
  queue << [x, y, z - 1] if z > 0 && space[z - 1][x, y] == '.'
  queue << [x, y, z + 1] if z < space.size - 1 && space[z + 1][x, y] == '.'
end

space.map(&:print)

sa = surface_area(data)
puts sa

hidden_cubes = []
space.each_with_index do |layer, z|
  layer.each do |v, x, y|
    hidden_cubes << [x, y, z] if v == '.'
  end
end

puts sa - surface_area(hidden_cubes)
