#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/product'
require_relative 'lib/product_catalog'
require_relative 'lib/delivery_charge_calculator'
require_relative 'lib/delivery_charge_rules'
require_relative 'lib/offers/buy_one_get_second_half_price'
require_relative 'lib/basket'

# Setup
catalog = ProductCatalog.new([
                               Product.new(code: 'R01', name: 'Red Widget', price: 32.95),
                               Product.new(code: 'G01', name: 'Green Widget', price: 24.95),
                               Product.new(code: 'B01', name: 'Blue Widget', price: 7.95)
                             ])

delivery_rules = DeliveryChargeRules.default
delivery_calculator = DeliveryChargeCalculator.new(delivery_rules)
offers = [BuyOneGetSecondHalfPrice.new(product_code: 'R01')]

puts "Acme Widget Co - Shopping Basket Examples\n\n"

# Example 1: B01, G01
basket1 = Basket.new(
  catalog: catalog,
  delivery_calculator: delivery_calculator,
  offers: offers
)
basket1.add('B01')
basket1.add('G01')
puts "B01, G01: $#{format('%.2f', basket1.total)}"

# Example 2: R01, R01
basket2 = Basket.new(
  catalog: catalog,
  delivery_calculator: delivery_calculator,
  offers: offers
)
basket2.add('R01')
basket2.add('R01')
puts "R01, R01: $#{format('%.2f', basket2.total)}"

# Example 3: R01, G01
basket3 = Basket.new(
  catalog: catalog,
  delivery_calculator: delivery_calculator,
  offers: offers
)
basket3.add('R01')
basket3.add('G01')
puts "R01, G01: $#{format('%.2f', basket3.total)}"

# Example 4: B01, B01, R01, R01, R01
basket4 = Basket.new(
  catalog: catalog,
  delivery_calculator: delivery_calculator,
  offers: offers
)
basket4.add('B01')
basket4.add('B01')
basket4.add('R01')
basket4.add('R01')
basket4.add('R01')
puts "B01, B01, R01, R01, R01: $#{format('%.2f', basket4.total)}"
