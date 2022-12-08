require_relative 'skim'

map = Skim.read(num: true)

nvis = 0
map.each do |h, x, y|
  vis = false
  vis ||= true if (0...x).all? { |a| map[a, y] < h }
  vis ||= true if (x+1...map.width).all? { |a| map[a, y] < h }
  vis ||= true if (0...y).all? { |b| map[x, b] < h }
  vis ||= true if (y+1...map.height).all? { |b| map[x, b] < h}
  nvis += 1 if vis
end
puts nvis

mscen = 0
map.each do |h, x, y|
  dists = []
  [[0, 1], [0, -1], [1, 0], [-1, 0]].each do |da, db|
    a = x
    b = y
    dist = 0
    loop do
      a += da
      b += db
      break unless map.in_bounds?(a, b)
      dist += 1
      break if map[a, b] >= h
    end
    dists << dist
  end
  scen = dists.inject(:*)
  mscen = [scen, mscen].max
end
puts mscen
