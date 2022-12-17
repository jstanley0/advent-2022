# writes a graphviz dot file to visualize the cave system
# I wish I could say this helped

require_relative 'search'

Valve = Struct.new(:name, :flow, :links)

valves = {}
ARGF.each do |line|
  break unless line =~ /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/
  valve = Valve.new($1, $2.to_i, $3.split(', '))
  valves[valve.name] = valve
end

puts "digraph D {"
puts "  concentrate=true;\n\n"
valves.values.each do |v|
  puts "  #{v.name} [ color=#{v.flow > 0 ? '"blue"' : '"black"'} shape=#{v.name == 'AA' ? "diamond" : (v.flow > 0 ? "box" : "circle")} label=<#{v.name}#{v.flow > 0 ? "<BR/><B>#{v.flow}</B>" : ""}>];"
end
puts
valves.values.each do |v|
  v.links.each do |dest|
    puts "  #{v.name} -> #{dest};"
  end
end
puts "}"
