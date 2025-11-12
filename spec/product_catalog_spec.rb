# frozen_string_literal: true

require 'rspec'
require_relative '../lib/product_catalog'
require_relative '../lib/product'

RSpec.describe ProductCatalog do
  let(:red_widget) { Product.new(code: 'R01', name: 'Red Widget', price: 32.95) }
  let(:green_widget) { Product.new(code: 'G01', name: 'Green Widget', price: 24.95) }
  let(:blue_widget) { Product.new(code: 'B01', name: 'Blue Widget', price: 7.95) }

  describe '#initialize' do
    it 'creates an empty catalog when no products provided' do
      catalog = described_class.new
      expect(catalog.all).to be_empty
    end

    it 'creates a catalog with products' do
      catalog = described_class.new([red_widget, green_widget])
      expect(catalog.all.size).to eq(2)
    end

    it 'handles duplicate product codes by keeping the last one' do
      duplicate = Product.new(code: 'R01', name: 'Another Red', price: 50)
      catalog = described_class.new([red_widget, duplicate])

      found = catalog.find('R01')
      expect(found.name).to eq('Another Red')
    end
  end

  describe '#find' do
    let(:catalog) { described_class.new([red_widget, green_widget, blue_widget]) }

    it 'finds product by exact code' do
      expect(catalog.find('R01')).to eq(red_widget)
    end

    it 'finds product by lowercase code' do
      expect(catalog.find('r01')).to eq(red_widget)
    end

    it 'finds product by mixed case code' do
      expect(catalog.find('R01')).to eq(red_widget)
    end

    it 'returns nil for non-existent product code' do
      expect(catalog.find('INVALID')).to be_nil
    end

    it 'handles symbol input' do
      expect(catalog.find(:r01)).to eq(red_widget)
    end
  end

  describe '#all' do
    it 'returns all products' do
      catalog = described_class.new([red_widget, green_widget])
      expect(catalog.all).to contain_exactly(red_widget, green_widget)
    end

    it 'returns empty array for empty catalog' do
      catalog = described_class.new
      expect(catalog.all).to eq([])
    end
  end
end
