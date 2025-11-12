# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/offers/buy_one_get_second_half_price'
require_relative '../../lib/product'

RSpec.describe BuyOneGetSecondHalfPrice do
  let(:red_widget) { Product.new(code: 'R01', name: 'Red Widget', price: 32.95) }
  let(:green_widget) { Product.new(code: 'G01', name: 'Green Widget', price: 24.95) }
  let(:offer) { described_class.new(product_code: 'R01') }

  describe '#apply' do
    it 'returns 0 discount for empty items' do
      expect(offer.apply([])).to eq(BigDecimal('0'))
    end

    it 'returns 0 discount for one matching item' do
      items = [{ product: red_widget, quantity: 1 }]
      expect(offer.apply(items)).to eq(BigDecimal('0'))
    end

    it 'applies discount to second matching item' do
      items = [
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      expected_discount = red_widget.price / 2
      expect(offer.apply(items)).to eq(expected_discount)
    end

    it 'applies discount to second and fourth items' do
      items = [
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      expected_discount = red_widget.price
      expect(offer.apply(items)).to eq(expected_discount)
    end

    it 'ignores non-matching products' do
      items = [
        { product: green_widget, quantity: 1 },
        { product: red_widget, quantity: 1 },
        { product: green_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      expected_discount = red_widget.price / 2
      expect(offer.apply(items)).to eq(expected_discount)
    end

    it 'handles mixed products correctly' do
      items = [
        { product: red_widget, quantity: 1 },
        { product: green_widget, quantity: 1 },
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      # Only red widgets at positions 2 and 4 in the filtered array get discount
      # That's only the 2nd red widget (index 1)
      expected_discount = red_widget.price / 2
      expect(offer.apply(items)).to eq(expected_discount)
    end

    it 'is case-insensitive for product codes' do
      offer_lowercase = described_class.new(product_code: 'r01')
      items = [
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      expected_discount = red_widget.price / 2
      expect(offer_lowercase.apply(items)).to eq(expected_discount)
    end

    it 'returns BigDecimal' do
      items = [
        { product: red_widget, quantity: 1 },
        { product: red_widget, quantity: 1 }
      ]
      expect(offer.apply(items)).to be_a(BigDecimal)
    end
  end
end
