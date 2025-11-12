# frozen_string_literal: true

require 'rspec'
require_relative '../lib/product'

RSpec.describe Product do
  describe '#initialize' do
    it 'creates a product with valid attributes' do
      product = described_class.new(code: 'R01', name: 'Red Widget', price: 32.95)

      expect(product.code).to eq('R01')
      expect(product.name).to eq('Red Widget')
      expect(product.price).to eq(BigDecimal('32.95'))
    end

    it 'normalizes product code to uppercase' do
      product = described_class.new(code: 'r01', name: 'Red Widget', price: 32.95)
      expect(product.code).to eq('R01')
    end

    it 'converts price to BigDecimal' do
      product = described_class.new(code: 'R01', name: 'Red Widget', price: '32.95')
      expect(product.price).to be_a(BigDecimal)
    end

    it 'handles integer prices' do
      product = described_class.new(code: 'R01', name: 'Red Widget', price: 10)
      expect(product.price).to eq(BigDecimal('10'))
    end

    it 'handles float prices without precision loss' do
      product = described_class.new(code: 'R01', name: 'Red Widget', price: 0.1)
      expect(product.price).to eq(BigDecimal('0.1'))
    end
  end

  describe '#==' do
    it 'returns true for products with same code' do
      product1 = described_class.new(code: 'R01', name: 'Red Widget', price: 32.95)
      product2 = described_class.new(code: 'R01', name: 'Different Name', price: 10.00)

      expect(product1).to eq(product2)
    end

    it 'returns false for products with different codes' do
      product1 = described_class.new(code: 'R01', name: 'Red Widget', price: 32.95)
      product2 = described_class.new(code: 'G01', name: 'Red Widget', price: 32.95)

      expect(product1).not_to eq(product2)
    end

    it 'returns false when comparing with non-Product object' do
      product = described_class.new(code: 'R01', name: 'Red Widget', price: 32.95)
      expect(product).not_to eq('R01')
    end
  end

  describe '#hash and #eql?' do
    it 'allows products to be used as hash keys' do
      product1 = described_class.new(code: 'R01', name: 'Red Widget', price: 32.95)
      product2 = described_class.new(code: 'R01', name: 'Different', price: 10)

      hash = { product1 => 'value' }
      expect(hash[product2]).to eq('value')
    end
  end
end
