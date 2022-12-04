require 'active_support'
require 'active_support/core_ext'
pairs = []
ARGF.map do |line|
  pairs << line.split(',').map{_1.split('-').map(&:to_i)}.map{Range.new(*_1)}
end
p pairs.count { |a, b| a.cover?(b) || b.cover?(a) }
p pairs.count { |a, b| a.overlaps?(b) }
