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
visited << knots[9].dup

ARGF.map do |line|
  dir, dist = line.split
  dir = dir.to_sym
  dist = dist.to_i

  dist.times do
    dx, dy = DELTAS[dir]
    prev = knots.map(&:dup)
    knots[0].x += dx
    knots[0].y += dy

    1.upto(9) do |i|
      # hx, hy are the head (previous) coords; dx, dy are the direction they moved
      hx = knots[i - 1].x
      dx = hx - prev[i - 1].x
      hy = knots[i - 1].y
      dy = hy - prev[i - 1].y

      # if the leading knot didn't move, we are done with this iteration
      # (none of the rest of the knots will move)
      break if dx == 0 && dy == 0

      # if the leading knot is too far away, we need to move
      if (hx - knots[i].x).abs > 1 || (hy - knots[i].y).abs > 1
        # move one step toward the head on each axis
        knots[i].x += hx <=> knots[i].x
        knots[i].y += hy <=> knots[i].y
      end
    end

    #visualize_places(knots)
    visited << knots[9].dup
  end
end

visualize_visitation(visited)
puts visited.size
