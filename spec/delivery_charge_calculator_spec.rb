# frozen_string_literal: true

require 'rspec'
require_relative '../lib/delivery_charge_calculator'
require_relative '../lib/delivery_charge_rules'

RSpec.describe DeliveryChargeCalculator do
  let(:rules) { DeliveryChargeRules.default }
  let(:calculator) { described_class.new(rules) }

  describe '#calculate' do
    it 'charges 4.95 for orders under 50' do
      expect(calculator.calculate(BigDecimal('49.99'))).to eq(BigDecimal('4.95'))
    end

    it 'charges 2.95 for orders between 50 and 89.99' do
      expect(calculator.calculate(BigDecimal('50.00'))).to eq(BigDecimal('2.95'))
      expect(calculator.calculate(BigDecimal('75.00'))).to eq(BigDecimal('2.95'))
      expect(calculator.calculate(BigDecimal('89.99'))).to eq(BigDecimal('2.95'))
    end

    it 'charges 0 for orders 90 and above' do
      expect(calculator.calculate(BigDecimal('90.00'))).to eq(BigDecimal('0'))
      expect(calculator.calculate(BigDecimal('150.00'))).to eq(BigDecimal('0'))
    end

    it 'handles boundary values correctly' do
      expect(calculator.calculate(BigDecimal('0'))).to eq(BigDecimal('4.95'))
      expect(calculator.calculate(BigDecimal('49.99'))).to eq(BigDecimal('4.95'))
      expect(calculator.calculate(BigDecimal('50.00'))).to eq(BigDecimal('2.95'))
      expect(calculator.calculate(BigDecimal('89.99'))).to eq(BigDecimal('2.95'))
      expect(calculator.calculate(BigDecimal('90.00'))).to eq(BigDecimal('0'))
    end

    it 'returns BigDecimal' do
      result = calculator.calculate(BigDecimal('25'))
      expect(result).to be_a(BigDecimal)
    end
  end

  describe 'with custom rules' do
    let(:custom_rules) do
      DeliveryChargeRules.new([
                                { threshold: 100, charge: 0 },
                                { threshold: 0, charge: 9.95 }
                              ])
    end
    let(:custom_calculator) { described_class.new(custom_rules) }

    it 'applies custom rules correctly' do
      expect(custom_calculator.calculate(BigDecimal('50'))).to eq(BigDecimal('9.95'))
      expect(custom_calculator.calculate(BigDecimal('100'))).to eq(BigDecimal('0'))
    end
  end
end
