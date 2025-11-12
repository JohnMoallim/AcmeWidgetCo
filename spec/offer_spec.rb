# frozen_string_literal: true

require 'rspec'
require_relative '../lib/offer'

RSpec.describe Offer do
  describe '#apply' do
    it 'raises NotImplementedError' do
      offer = described_class.new
      expect { offer.apply([]) }.to raise_error(NotImplementedError, /must implement #apply/)
    end
  end

  describe '#count_items_by_code' do
    let(:offer) { Class.new(Offer) { public :count_items_by_code }.new }
    let(:product1) { double('Product', code: 'R01') }
    let(:product2) { double('Product', code: 'G01') }

    it 'counts items with matching code' do
      items = [
        { product: product1, quantity: 1 },
        { product: product1, quantity: 1 },
        { product: product2, quantity: 1 }
      ]

      expect(offer.count_items_by_code(items, 'R01')).to eq(2)
    end

    it 'returns 0 for non-matching code' do
      items = [{ product: product1, quantity: 1 }]
      expect(offer.count_items_by_code(items, 'INVALID')).to eq(0)
    end
  end
end
