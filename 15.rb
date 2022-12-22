require_relative 'ranger'

Coord = Struct.new(:x, :y)
Sensor = Struct.new(:pos, :beacon, :radius)

def mdist(a, b)
  (b.x - a.x).abs + (b.y - a.y).abs
end

# returns a Range where the sensor coverage intercepts the row
def project(sensor, row)
  vdist = (sensor.pos.y - row).abs
  half_width = sensor.radius - vdist
  return nil if half_width < 0
  sensor.pos.x - half_width .. sensor.pos.x + half_width
end

max_coord = ARGV[0].include?('ex') ? 20 : 4000000
intercept_row = ARGV[0].include?('ex') ? 10 : 2000000

data = File.readlines(ARGV[0]).map do |line|
  break unless line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
  Sensor.new(Coord.new($1.to_i, $2.to_i), Coord.new($3.to_i, $4.to_i)).tap do |s|
    s.radius = mdist(s.beacon, s.pos)
  end
end

def excluded_ranges(data, intercept_row)
  ranges = data.map { |sensor| project(sensor, intercept_row) }.compact
  Ranger.union(*ranges)
end

xr = excluded_ranges(data, intercept_row)
pp xr
puts xr.sum{ _1.last - _1.first }

(0..max_coord).each do |y|
  xr = excluded_ranges(data, y)
  puts (xr[0].last + 1) * 4000000 + y if xr.size > 1
end
