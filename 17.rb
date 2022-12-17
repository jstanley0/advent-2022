require_relative 'skim'

class ThingStreamer
  attr_accessor :container, :index

  def initialize(container)
    self.container = container
    self.index = 0
  end

  def next(reset = false)
    self.index = 0 if reset
    thing = container[index]
    self.index = (index + 1) % container.size
    thing
  end
end

rocks = ThingStreamer.new(Skim.read_many(<<DATA))
####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##
DATA

jets = ThingStreamer.new(ARGF.gets.chomp.chars.map{_1 == '<' ? -1 : 1})

well = Skim.new(7, 10, '.')

heights = 5000.times.map do
  _, highest_rock = well.find_coords('#') || [0, well.height]
  if highest_rock < 10
    well.insert_rows!(10, '.', pos: 0)
    highest_rock += 10
  end

  new_rock = rocks.next
  x = 2
  y = highest_rock - new_rock.height - 3
  #well.dup.overlay(x, y, rock) { |s| s.tr('#', '@') }.print

  land = false
  loop do
    # horizontal motion
    bump = false
    dx = jets.next
    well.overlay(x + dx, y, new_rock) { |src, dst| bump = true if src != '.' && dst != '.'; dst }
    x += dx unless bump

    # falling motion
    well.overlay(x, y + 1, new_rock) { |src, dst| land = true if src != '.' && dst != '.'; dst }
    break if land
    y += 1
  end
  well.overlay(x, y, new_rock) { |src, dst| src == '#' ? src : dst }
  _, y = well.find_coords('#')
  well.height - y
end
puts heights[2021]

# returns [offset, size] where input starts repeating
def find_cycle(input)
  a = 0
  b = 1
  while b < input.size do
    # detect a repeated value
    while b < input.size && input[a] != input[b] do
      b += 2
      a += 1
    end
    break unless b < input.size
    w = b - a

    # see if a cycle of this period exists
    # look left
    c = a
    c -= 1 while c + w >= a && input[c] == input[c + w]
    c += 1

    # look right
    d = a
    d += 1 while d + w < input.size && input[d] == input[d + w]

    # if we repeated at least one period and all the way to the end of the input,
    # we've found what we're looking for
    return c, w if d - c >= w && d + w == input.size

    # keep looking
    b += 2
    a += 1
  end
  nil
end

diffs = heights.each_cons(2).map{_2 - _1}
offset, size = find_cycle(diffs)
raise "no cycle detected" unless offset

count_per_cycle = diffs[offset, size].sum
cycles_to_elide, remainder = (1000000000000 - offset - 1).divmod size

p heights[offset + remainder] + cycles_to_elide * count_per_cycle
