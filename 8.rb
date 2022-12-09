require_relative 'skim'

grid = Skim.read(num: true)

nvis = 0
grid.each do |h, x, y|
  vis = false
  vis ||= true if (0...x).all? { |a| grid[a, y] < h }
  vis ||= true if (x+1...grid.width).all? { |a| grid[a, y] < h }
  vis ||= true if (0...y).all? { |b| grid[x, b] < h }
  vis ||= true if (y+1...grid.height).all? { |b| grid[x, b] < h}
  nvis += 1 if vis
end
puts nvis

mscen = 0
grid.each do |h, x, y|
  dists = []
  [[0, 1], [0, -1], [1, 0], [-1, 0]].each do |da, db|
    a = x
    b = y
    dist = 0
    loop do
      a += da
      b += db
      break unless grid.in_bounds?(a, b)
      dist += 1
      break if grid[a, b] >= h
    end
    dists << dist
  end
  scen = dists.inject(:*)
  mscen = [scen, mscen].max
end
puts mscen
