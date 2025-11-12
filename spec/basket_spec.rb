# frozen_string_literal: true

require 'rspec'
require 'bigdecimal'
require_relative '../lib/basket'
require_relative '../lib/product'
require_relative '../lib/product_catalog'
require_relative '../lib/delivery_charge_calculator'
require_relative '../lib/delivery_charge_rules'
require_relative '../lib/offers/buy_one_get_second_half_price'

RSpec.describe Basket do
  let(:red_widget) { Product.new(code: 'R01', name: 'Red Widget', price: 32.95) }
  let(:green_widget) { Product.new(code: 'G01', name: 'Green Widget', price: 24.95) }
  let(:blue_widget) { Product.new(code: 'B01', name: 'Blue Widget', price: 7.95) }

  let(:catalog) do
    ProductCatalog.new([red_widget, green_widget, blue_widget])
  end

  let(:delivery_rules) { DeliveryChargeRules.default }
  let(:delivery_calculator) { DeliveryChargeCalculator.new(delivery_rules) }
  let(:offers) { [BuyOneGetSecondHalfPrice.new(product_code: 'R01')] }

  let(:basket) do
    described_class.new(
      catalog: catalog,
      delivery_calculator: delivery_calculator,
      offers: offers
    )
  end

  describe '#initialize' do
    it 'creates a basket with required dependencies' do
      expect(basket).to be_a(described_class)
    end

    it 'creates a basket without offers' do
      basket_no_offers = described_class.new(
        catalog: catalog,
        delivery_calculator: delivery_calculator
      )
      expect(basket_no_offers).to be_a(described_class)
    end
  end

  describe '#add' do
    it 'adds a product to the basket' do
      basket.add('B01')
      expect(basket.total).to eq(12.90)
    end

    it 'adds multiple products' do
      basket.add('B01')
      basket.add('G01')
      expect(basket.total).to eq(37.85)
    end

    it 'is case-insensitive' do
      basket.add('b01')
      expect(basket.total).to eq(12.90)
    end

    it 'raises error for invalid product code' do
      expect { basket.add('INVALID') }.to raise_error(ArgumentError, /Product not found/)
    end

    it 'raises error for nil product code' do
      expect { basket.add(nil) }.to raise_error(ArgumentError, /Product not found/)
    end
  end

  describe '#total' do
    context 'required test scenarios' do
      it 'calculates total for B01, G01' do
        basket.add('B01')
        basket.add('G01')
        expect(basket.total).to eq(37.85)
      end

      it 'calculates total for R01, R01' do
        basket.add('R01')
        basket.add('R01')
        expect(basket.total).to eq(54.37)
      end

      it 'calculates total for R01, G01' do
        basket.add('R01')
        basket.add('G01')
        expect(basket.total).to eq(60.85)
      end

      it 'calculates total for B01, B01, R01, R01, R01' do
        basket.add('B01')
        basket.add('B01')
        basket.add('R01')
        basket.add('R01')
        basket.add('R01')
        expect(basket.total).to eq(98.27)
      end
    end

    context 'edge cases' do
      it 'includes delivery charge for empty basket' do
        # Empty basket still has delivery charge for orders under $50
        expect(basket.total).to eq(4.95)
      end

      it 'calculates single item total' do
        basket.add('B01')
        expect(basket.total).to eq(12.90) # 7.95 + 4.95 delivery
      end
    end

    context 'with no offers' do
      let(:basket_no_offers) do
        described_class.new(
          catalog: catalog,
          delivery_calculator: delivery_calculator,
          offers: []
        )
      end

      it 'calculates total without discounts' do
        basket_no_offers.add('R01')
        basket_no_offers.add('R01')
        # 32.95 * 2 = 65.90 + 2.95 delivery = 68.85
        expect(basket_no_offers.total).to eq(68.85)
      end
    end

    context 'delivery charge thresholds' do
      let(:basket_no_offers) do
        described_class.new(
          catalog: catalog,
          delivery_calculator: delivery_calculator,
          offers: []
        )
      end

      it 'charges 4.95 for orders under 50' do
        basket_no_offers.add('B01') # 7.95
        expect(basket_no_offers.total).to eq(12.90) # 7.95 + 4.95
      end

      it 'charges 2.95 for orders between 50 and 90' do
        2.times { basket_no_offers.add('G01') } # 49.90
        basket_no_offers.add('B01') # 57.85 total
        expect(basket_no_offers.total).to eq(60.80) # 57.85 + 2.95
      end

      it 'charges 0 for orders 90 and above' do
        3.times { basket_no_offers.add('R01') } # 98.85
        expect(basket_no_offers.total).to eq(98.85) # no delivery charge
      end
    end
  end
end
