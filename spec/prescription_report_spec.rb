# frozen_string_literal: true

require 'prescription_report'

describe PrescriptionReport do
  describe 'call' do
    subject { described_class.new("spec/support/#{filename}").call }

    context 'given an empty txt file' do
      let(:filename) { 'example_0.txt' }
      let(:expected_result) { [] }

      it { is_expected.to eq(expected_result) }
    end

    context 'given example_1.txt file' do
      let(:filename) { 'example_1.txt' }
      let(:expected_result) do
        [
          'Nick: 0 fills $0 income',
          'Mark: 2 fills $9 income',
          'John: 0 fills -$1 income'
        ]
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'given example_2.txt file' do
      let(:filename) { 'example_2.txt' }
      let(:expected_result) do
        [
          'Alex: 2 fills $5 income',
          'Bob: 3 fills $14 income'
        ]
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'given example_3.txt file' do
      let(:filename) { 'example_3.txt' }
      let(:expected_result) do
        [
          'Alex: 0 fills -$12 income',
          'Bob: 0 fills $0 income'
        ]
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'given example without created' do
      let(:filename) { 'example_4.txt' }
      let(:expected_result) { [] }

      it { is_expected.to eq(expected_result) }
    end
  end
end
