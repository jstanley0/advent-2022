# this hack solves the example but not the real data in any reasonable amount of time

Valve = Struct.new(:name, :flow, :links)

valves = {}
ARGF.each do |line|
  break unless line =~ /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/
  valve = Valve.new($1, $2.to_i, $3.split(', '))
  valves[valve.name] = valve
end

def max_pressure(valves, best_states, pressure_so_far = 0, open = [], locations = ['AA', 'AA'], time_left = 26, index = 0)
  return pressure_so_far if time_left == 0

  state_hash = locations.join + "/" + open.sort.join
  prev_time_left, prev_pressure_released = best_states[state_hash]
  if prev_time_left
    return 0 if prev_time_left >= time_left && prev_pressure_released >= pressure_so_far
  end
  best_states[state_hash] = [time_left, pressure_so_far]

  max_p = 0
  next_tick = index > 0 ? time_left - 1 : time_left
  next_index = index > 0 ? 0 : 1
  if valves[locations[index]].flow > 0 && !open.include?(locations[index])
    p = max_pressure(valves, best_states, pressure_so_far + valves[locations[index]].flow * (time_left - 1), open + [locations[index]], locations, next_tick, next_index)
    max_p = p if p > max_p
  end
  valves[locations[index]].links.each do |connection|
    p = max_pressure(valves, best_states, pressure_so_far, open, locations.dup.tap{_1[index]=connection}, next_tick, next_index)
    max_p = p if p > max_p
  end
  puts ($bp = max_p) if max_p > $bp
  max_p
end

best_states = Hash.new
$bp = 0
puts max_pressure(valves, best_states)
