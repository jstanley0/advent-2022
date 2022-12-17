Valve = Struct.new(:name, :flow, :links)

valves = {}
ARGF.each do |line|
  break unless line =~ /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/
  valve = Valve.new($1, $2.to_i, $3.split(', '))
  valves[valve.name] = valve
end

def max_pressure(valves, best_states, pressure_so_far = 0, open = [], location = 'AA', time_left = 30)
  return pressure_so_far if time_left == 0

  state_hash = location + "/" + open.sort.join
  prev_time_left, prev_pressure_released = best_states[state_hash]
  if prev_time_left
    return 0 if prev_time_left >= time_left && prev_pressure_released >= pressure_so_far
  end
  best_states[state_hash] = [time_left, pressure_so_far]

  max_p = 0
  if valves[location].flow > 0 && !open.include?(location)
    p = max_pressure(valves, best_states, pressure_so_far + valves[location].flow * (time_left - 1), open + [location], location, time_left - 1)
    max_p = p if p > max_p
  end
  valves[location].links.each do |connection|
    p = max_pressure(valves, best_states, pressure_so_far, open, connection, time_left - 1)
    max_p = p if p > max_p
  end
  max_p
end

best_states = Hash.new
puts max_pressure(valves, best_states)
