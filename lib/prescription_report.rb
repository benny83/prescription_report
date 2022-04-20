class PrescriptionReport
  EVENTS = {
    created: 'created',
    filled: 'filled',
    returned: 'returned'
  }.freeze
  CURRENCY = '$'.freeze
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
    filtered_data.merge!(*grouped_data) { |_, prev, val| Array(prev) << val }
  end

  def skip_incomplete_data
    filtered_data.each do |patient, event|
      next if event =~ /#{EVENTS[:filled]}|#{EVENTS[:returned]}/

      report[patient.split.first] ||= []
      next if event == EVENTS[:created]

      first_filling_index = event.index(EVENTS[:created]) + 1
      report[patient.split.first] += event.drop(first_filling_index)
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
