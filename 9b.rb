require 'set'
require_relative 'skim'

def plot_board(things)
  xr = things.map(&:x).concat([0]).minmax
  yr = things.map(&:y).concat([0]).minmax
  skim = Skim.new(xr[1] - xr[0] + 1, yr[1] - yr[0] + 1, '.')
  skim[0 - xr[0], 0 - yr[0]] = 's'
  [skim, xr[0], yr[0]]
end

def visualize_places(knots)
  skim, x0, y0 = plot_board(knots)
  knots.each_with_index.reverse_each do |knot, i|
    skim[knot.x - x0, knot.y - y0] = i == 0 ? 'H' : i.to_s
  end
  skim.print
end

def visualize_visitation(visited)
  skim, x0, y0 = plot_board(visited)
  visited.each { skim[_1.x - x0, _1.y - y0] = '#' }
  skim.print
end

DELTAS = {
  D: [0, 1],
  R: [1, 0],
  L: [-1, 0],
  U: [0, -1]
}

Coord = Struct.new(:x, :y)
knots = 10.times.map { Coord.new(0, 0) }

visited = Set.new
visited << knots.last.dup

ARGF.map do |line|
  dir, dist = line.split
  dir = dir.to_sym
  dist = dist.to_i

  dist.times do
    dx, dy = DELTAS[dir]
    knots[0].x += dx
    knots[0].y += dy

    knots.each_cons(2) do |h, t|
      if (h.x - t.x).abs > 1 || (h.y - t.y).abs > 1
        t.x += h.x <=> t.x
        t.y += h.y <=> t.y
      end
    end

    #visualize_places(knots)
    visited << knots.last.dup
  end
end

visualize_visitation(visited)
puts visited.size
