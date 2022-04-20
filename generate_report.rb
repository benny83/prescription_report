#!/usr/bin/env ruby

require_relative('lib/prescription_report')

if (ARGV & %w[-d --details]).any?
  puts ['File:', File.open(ARGV[0]).read(), "\nReport:"]
end

puts PrescriptionReport.new(ARGV[0]).call
