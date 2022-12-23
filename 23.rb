require_relative 'skim'
require 'set'

elves = Set.new
Skim.read.each do |c, x, y|
  next unless c == '#'
  elves << [x, y]
end

def visualize(elves)
  x0, x1 = elves.map { _1[0] }.minmax
  y0, y1 = elves.map { _1[1] }.minmax
  mapp = Skim.new(x1 - x0 + 1, y1 - y0 + 1, '.')
  elves.each do |x, y|
    mapp[x - x0, y - y0] = '#'
  end
  mapp.print
  puts mapp.count('.')
end

ADJACENT = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

DELTAS = {
  N: [[0, -1], [-1, -1], [1, -1]],
  S: [[0, 1], [-1, 1], [1, 1]],
  W: [[-1, 0], [-1, -1], [-1, 1]],
  E: [[1, 0], [1, -1], [1, 1]]
}.freeze

order = %i[N S W E]

(1..).each do |round|
  moves = {} # dest => [array of sources]
  elves.each do |x, y|
    next if ADJACENT.all? { |dx, dy| !elves.include?([x + dx, y + dy]) }
    order.each do |dir|
      if DELTAS[dir].all? { |dx, dy| !elves.include?([x + dx, y + dy]) }
        target = [x + DELTAS[dir][0][0], y + DELTAS[dir][0][1]]
        (moves[target] ||= []) << [x, y]
        break
      end
    end
  end

  moved = 0
  moves.each do |target, sources|
    raise "whoops" if elves.include?(target)
    next if sources.size != 1
    elves.delete(sources[0])
    elves << target
    moved += 1
  end

  visualize(elves) if round == 10

  if moved == 0
    visualize(elves)
    puts round
    break
  end

  order.rotate!(1)
end

