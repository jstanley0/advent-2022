require 'set'

DELTAS = {
  D: [0, 1],
  R: [1, 0],
  L: [-1, 0],
  U: [0, -1]
}

hx, hy = [0, 0]
tx, ty = [0, 0]

visited = Set.new
visited << [tx, ty]

ARGF.map do |line|
  dir, dist = line.split
  dir = dir.to_sym
  dist = dist.to_i

  dx, dy = DELTAS[dir]
  dist.times do
    hx += dx
    hy += dy

    if dx == 0
      # vertical
      if hx == tx
        # aligned
        ty += dy if (hy - ty).abs > 1
      else
        # diagonal
        if (hx - tx).abs > 1 || (hy - ty).abs > 1
          tx = hx
          ty = hy - dy
        end
      end
    elsif dy == 0
      # horizontal
      if hy == ty
        # aligned
        tx += dx if (hx - tx).abs > 1
      else
        # diagonal
        if (hx - tx).abs > 1 || (hy - ty).abs > 1
          ty = hy
          tx = hx - dx
        end
      end
    end

    visited << [tx, ty]
  end
end

puts visited.size
