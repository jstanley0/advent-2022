require_relative 'skim'
require_relative 'search'

$mapp = Skim.read
$bw, $bh = $mapp.width - 2, $mapp.height - 2

$blizzards = []
$mapp.each do |c, x, y|
  dx, dy = case c
  when '^' then [0, -1]
  when 'v' then [0, 1]
  when '<' then [-1, 0]
  when '>' then [1, 0]
  else next
  end
  $blizzards << [x - 1, y - 1, dx, dy, c]
  $mapp[x, y] = '.'
end

def map_at_t(t)
  $cache ||= {}
  return $cache[t] if $cache.key?(t)

  mapp = $mapp.dup
  $blizzards.each do |x, y, dx, dy, c|
    new_x = 1 + (x + dx * t) % $bw
    new_y = 1 + (y + dy * t) % $bh
    mapp[new_x, new_y] = c
  end
  $cache[t] = mapp
end

class SearchNode < Search::Node
  attr_accessor :t, :x, :y

  def initialize(t, x, y)
    self.t = t
    self.x = x
    self.y = y
  end

  def enum_edges
    next_map = map_at_t(t + 1)
    yield 1, SearchNode.new(t + 1, x, y) if next_map[x, y] == '.'
    next_map.nabes(x, y, diag: false) do |c, a, b|
      yield 1, SearchNode.new(t + 1, a, b) if c == '.'
    end
  end

  def est_cost(other)
    (other.x - x).abs + (other.y - y).abs
  end

  def hash
    [t, x, y].hash
  end

  def fuzzy_equal?(other)
    x == other.x && y == other.y
  end
end

start_x, start_y = $mapp.data.first.index('.'), 0
end_x, end_y = $mapp.data.last.index('.'), $mapp.data.size - 1
t = Search::a_star(SearchNode.new(0, start_x, start_y), SearchNode.new(nil, end_x, end_y)).first
puts t

t1 = Search::a_star(SearchNode.new(t, end_x, end_y), SearchNode.new(nil, start_x, start_y)).first
puts t1

t2 = Search::a_star(SearchNode.new(t + t1, start_x, start_y), SearchNode.new(nil, end_x, end_y)).first
puts t2

puts t + t1 + t2


