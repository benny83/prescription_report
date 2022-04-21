# frozen_string_literal: true

class PrescriptionReport
  EVENTS = { created: 'created', filled: 'filled', returned: 'returned' }.freeze
  CURRENCY = '$'
  FILLING_COST = 5
  RETURNING_COST = 1

  def initialize(filename)
    @file = File.open(filename)
    @filtered_data = {}
    @report = {}
  end

  def call
    grouped_data = fetch_by_patient_and_drug
    merge_events(grouped_data)
    skip_incomplete_data
    render_report
  end

  private

  attr_accessor :filtered_data, :report

  def fetch_by_patient_and_drug
    @file.readlines.map { |s| Hash[*s.chomp.rpartition(/ /).values_at(0, 2)] }
  end

  def merge_events(grouped_data)
    grouped_data.each_with_object(filtered_data) do |pair, memo|
      memo[pair.keys.first] ||= []
      memo[pair.keys.first] << pair.values.first
    end
  end

  def skip_incomplete_data
    filtered_data.each do |patient, event|
      next unless event.include?(EVENTS[:created])

      report[patient.split.first] ||= []
      created_index = event.index(EVENTS[:created])
      report[patient.split.first] += event.drop(created_index)
    end
  end

  def render_report
    report.map do |patient_name, events|
      fills = events.count(EVENTS[:filled]) - events.count(EVENTS[:returned])

      income = fills * FILLING_COST - events.count(EVENTS[:returned]) * RETURNING_COST
      income = income.to_s.insert(income.negative? ? 1 : 0, CURRENCY)

      "#{patient_name}: #{fills} fills #{income} income"
    end
  end
end
