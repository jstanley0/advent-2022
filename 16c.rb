# this collapses away the uninteresting valves and makes a rest-area city distance chart thing
# and simulates a run given a permutation of valves, where the first available agent takes the next valve
# then uses a genetic algorithm to find the "best" permutation of valves
# ... there is no terminating condition, you just stop it after it stops improving

TIME_LIMIT = 26
WORKERS = 2

require_relative 'search'

Valve = Struct.new(:name, :flow, :links)

valves = {}
ARGF.each do |line|
  break unless line =~ /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/
  valve = Valve.new($1, $2.to_i, $3.split(', '))
  valves[valve.name] = valve
end

class ValveSearchNode < Search::Node
  attr_accessor :name, :valves, :result

  def initialize(name, valves, result)
    self.name = name
    self.valves = valves
    self.result = result
  end

  def enum_edges
    valves[name].links.each do |link|
      yield 1, ValveSearchNode.new(link, valves, result)
    end
  end

  def goal?
    if valves[name].flow > 0 && cost_heuristic > 0
      result[name] = [1 + cost_heuristic, valves[name].flow]
    end

    false
  end

  def hash
    name.hash
  end
end

legit_nodes = valves.values.select{_1.flow > 0}.map(&:name)
state_map = {}
(['AA'] + legit_nodes).each do |node|
  Search::bfs(ValveSearchNode.new(node, valves, state_map[node] = {}))
end

# pp state_map

def run_tour(state_map, tour)
  locations = ['AA'] * WORKERS
  times = [TIME_LIMIT] * WORKERS
  pressure_released = 0
  tour = tour.dup
  until tour.empty?
    turn = times.index(times.max)
    valve = tour.shift
    location = locations[turn]
    time_cost, flow_rate = state_map[location][valve]
    break if times[turn] < time_cost

    times[turn] -= time_cost
    locations[turn] = valve
    pressure_released += times[turn] * flow_rate
  end
  pressure_released
end

Solution = Struct.new(:tour, :score)

def breed(a, b)
  i0 = rand(a.tour.size)
  i1 = rand(a.tour.size)
  child = Solution.new(a.tour.map { nil }, 0)
  child.tour[i0..i1] = a.tour[i0..i1]
  j = 0
  child.tour.each_with_index do |val, i|
    if val.nil?
      j += 1 while child.tour.include?(b.tour[j])
      child.tour[i] = b.tour[j]
    end
  end
  child
end

def mutate(a)
  i0 = rand(a.tour.size)
  i1 = rand(a.tour.size)
  a.tour[i0], a.tour[i1] = a.tour[i1], a.tour[i0]
  a
end

POPULATION = 10000
KEEP_BEST = POPULATION / 10
BREED_BEST = POPULATION / 5
BREED_TIMES = (POPULATION - KEEP_BEST) / (BREED_BEST / 2)

population = POPULATION.times.map { Solution.new(legit_nodes.shuffle, 0) }

best_p = 0
loop do
  population.each { _1.score = run_tour(state_map, _1.tour) }
  population.sort_by!(&:score)

  p = population.last.score
  if p > best_p
    puts p
    best_p = p
  end

  next_gen = population[-KEEP_BEST..]
  population[-BREED_BEST..].each_slice(2) do |a, b|
    BREED_TIMES.times do
      next_gen << breed(a, b)
    end
  end

  population = next_gen.map { mutate _1 }
end
