# frozen_string_literal: true

require 'rspec'
require_relative '../lib/delivery_charge_rules'

RSpec.describe DeliveryChargeRules do
  describe '.default' do
    let(:rules) { described_class.default }

    it 'returns rules sorted by threshold descending' do
      thresholds = rules.rules.map { |r| r[:threshold] }
      expect(thresholds).to eq([90, 50, 0])
    end

    it 'has correct charges' do
      expect(rules.rules).to eq([
                                  { threshold: 90, charge: 0 },
                                  { threshold: 50, charge: 2.95 },
                                  { threshold: 0, charge: 4.95 }
                                ])
    end
  end

  describe '#initialize' do
    it 'sorts rules by threshold in descending order' do
      unsorted_rules = [
        { threshold: 0, charge: 5 },
        { threshold: 100, charge: 0 },
        { threshold: 50, charge: 2.5 }
      ]

      rules = described_class.new(unsorted_rules)
      thresholds = rules.rules.map { |r| r[:threshold] }

      expect(thresholds).to eq([100, 50, 0])
    end

    it 'handles empty rules' do
      rules = described_class.new([])
      expect(rules.rules).to be_empty
    end
  end
end
