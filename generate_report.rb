#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative('lib/prescription_report')

puts ['File:', File.open(ARGV[0]).read, "\nReport:"] if (ARGV & %w[-d --details]).any?
puts PrescriptionReport.new(ARGV[0]).call
