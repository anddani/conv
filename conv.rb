#!/usr/bin/env ruby

require 'set'

lines = ARGF.readlines.map(&:strip)

# Extract and join columns:
# 1-2-3-4
# 5-6-9
codes = lines.drop(1).map do |l|
  l.split(';')
end.map do |l|
  [l[0..3].join, (l[4..5] << l[8]).join].flatten
end

# Add distribution to each
# unique code
dist = Hash.new
codes.each do |m|
  dist[m[0]] ||= Set.new
  dist[m[0]].add(m[1])
end

# Count the number of identical
# distributions
count = Hash.new(0)
dist.each_value do |v|
  count[v] += 1
end

# Write distribution to small.csv
File.open("small.csv", "w+") do |f|
  f.puts("ACCOUD;COSTCD;FORDEL;COUNT")
  count.each_pair do |k,v|
    k.each do |d|
      f.puts("#{d[0..7]};#{d[8..12]};#{d[13..-1]};#{v}")
    end
  end
end

# Append count to line
new_lines = lines.drop(1).map do |l|
  l.split(';')
end.map do |l|
  [l, count[dist[l[0..3].join]]].join(";")
end

# Add new column name and write
# new lines to big.csv
new_lines.unshift(lines[0] + ";COUNT")
File.open("big.csv", "w+") do |f|
  new_lines.each{ |o| f.puts o }
end
