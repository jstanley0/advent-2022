require_relative 'skim'

mapp = Skim.read
x0, y0 = mapp.find_coords('S')
x1, y1 = mapp.find_coords('E')
mapp[x0, y0] = 'a'
mapp[x1, y1] = 'z'

puts mapp.a_star(x0, y0, x1, y1) { |from, to| to.ord <= from.ord + 1 }.first
puts mapp.bfs(x1, y1, goal: 'a') { |from, to| to.ord >= from.ord - 1 }.first
