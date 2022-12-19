require 'byebug'

Blueprint = Struct.new(:number, :ore_ore, :clay_ore, :obsidian_ore, :obsidian_clay, :geode_ore, :geode_obsidian)

# prioritized; :geode must come first
RESOURCE_TYPES = %i[geode obsidian clay ore]

class State
  attr_accessor :resources, :bots, :pending_bots

  def initialize(resources = Hash.new(0), bots = Hash.new(0), pending_bots = Hash.new(0))
    self.resources = resources
    self.bots = bots
    self.pending_bots = pending_bots
  end

  def dup
    State.new(resources.dup, bots.dup, pending_bots.dup)
  end

  def collect_resources
    bots.each do |type, count|
      resources[type] += count
    end
  end

  def robot_cost(bot_type, blueprint)
    cost = {}
    RESOURCE_TYPES.each do |res_type|
      attr = "#{bot_type}_#{res_type}".to_sym
      cost[res_type] = blueprint[attr] if blueprint.members.include?(attr)
    end
    cost
  end

  def count_affordable_bots(blueprint)
    afford = {}
    RESOURCE_TYPES.each do |bot_type|
      cost = robot_cost(bot_type, blueprint)
      afford[bot_type] = cost.keys.map { |res_type| resources[res_type] / cost[res_type] }.min
    end
    afford
  end

  def build_robot(bot_type, blueprint)
    cost = robot_cost(bot_type, blueprint)
    cost.keys.each do |res_type|
      resources[res_type] -= cost[res_type]
      raise "whoops" if resources[res_type] < 0
    end
    pending_bots[bot_type] += 1
  end

  def finish_robots
    pending_bots.keys.each do |bot_type|
      bots[bot_type] += pending_bots[bot_type]
      pending_bots[bot_type] = 0
    end
  end
end

blueprints = ARGF.map { |line| Blueprint.new(*line.scan(/\d+/).map(&:to_i)) }

def finish_round(state, blueprint, time_left, forbidden_bots)
  state.collect_resources
  state.finish_robots
  if time_left > 1
    count_geodes(state, blueprint, time_left - 1, forbidden_bots)
  else
    state.resources[:geode]
  end
end

def count_geodes(state, blueprint, time_left, forbidden_bots = [])
  geodes = 0

  afford = state.count_affordable_bots(blueprint)
  (RESOURCE_TYPES - forbidden_bots).each do |bot_type|
    count = afford[bot_type]
    next unless count > 0

    # determine if it makes any sense to build this bot
    # if we are already producing enough of this resource to build the most expensive bot, don't get more
    current_production = state.bots[bot_type]
    max_cost = blueprint.members.map { |member| blueprint[member] if member.to_s.end_with?("_#{bot_type}") }.compact.max
    next if max_cost && current_production >= max_cost

    new_state = state.dup
    new_state.build_robot(bot_type, blueprint)
    gc = finish_round(new_state, blueprint, time_left, [])
    geodes = [geodes, gc].max

    # if I can afford a geode bot, it doesn't make sense to *not* make one
    return geodes if bot_type == :geode
  end

  # if we can afford a type of bot now, we don't buy anything by building nothing now and that bot type next time
  gc = finish_round(state, blueprint, time_left, afford.select{_2 > 0}.keys)
  [geodes, gc].max
end

if ENV.key?("PART2")
  puts blueprints[0...3].map { |blueprint|
    initial_state = State.new
    initial_state.bots[:ore] = 1
    count = count_geodes(initial_state, blueprint, 32)
    puts "bp #{blueprint.number}: #{count}"
    count
  }.inject(:*)
else
  puts blueprints.sum { |blueprint|
    initial_state = State.new
    initial_state.bots[:ore] = 1
    count = count_geodes(initial_state, blueprint, 24)
    puts "bp #{blueprint.number}: #{count}"
    blueprint.number * count
  }
end
