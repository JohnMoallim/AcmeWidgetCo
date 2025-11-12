# frozen_string_literal: true

require 'bigdecimal'
require_relative 'product'
require_relative 'product_catalog'
require_relative 'delivery_charge_calculator'
require_relative 'delivery_charge_rules'
require_relative 'offer'

# Shopping basket implementation with support for delivery charges and special offers.
#
# The Basket class orchestrates the shopping basket functionality by coordinating
# between the product catalog, delivery charge calculator, and offer system.
# It maintains a collection of items and calculates the total price including
# discounts and delivery charges.
#
# @example Create a basket and add products
#   catalog = ProductCatalog.new([...])
#   calculator = DeliveryChargeCalculator.new(DeliveryChargeRules.default)
#   offers = [BuyOneGetSecondHalfPrice.new(product_code: 'R01')]
#
#   basket = Basket.new(
#     catalog: catalog,
#     delivery_calculator: calculator,
#     offers: offers
#   )
#
#   basket.add('R01')
#   basket.add('G01')
#   basket.total #=> 60.85
#
class Basket
  # Creates a new basket instance with the required dependencies.
  #
  # @param catalog [ProductCatalog] the product catalog for looking up products
  # @param delivery_calculator [DeliveryChargeCalculator] calculator for delivery charges
  # @param offers [Array<Offer>] array of special offers to apply (default: [])
  #
  # @example
  #   basket = Basket.new(
  #     catalog: catalog,
  #     delivery_calculator: calculator,
  #     offers: []
  #   )
  def initialize(catalog:, delivery_calculator:, offers: [])
    @catalog = catalog
    @delivery_calculator = delivery_calculator
    @offers = offers
    @items = []
  end

  # Adds a product to the basket by product code.
  #
  # Product codes are case-insensitive and will be normalized to uppercase
  # before lookup.
  #
  # @param product_code [String, Symbol] the code of the product to add
  #
  # @return [void]
  #
  # @raise [ArgumentError] if the product code doesn't exist in the catalog
  #
  # @example
  #   basket.add('R01')
  #   basket.add(:g01)  # symbols work too
  def add(product_code)
    product = @catalog.find(product_code)
    raise ArgumentError, "Product not found: #{product_code}" unless product

    @items << { product: product, quantity: 1 }
  end

  # Calculates the total price of the basket including discounts and delivery.
  #
  # The calculation follows this order:
  # 1. Calculate subtotal of all items
  # 2. Apply all offers to get total discount
  # 3. Calculate delivery charge based on (subtotal - discount)
  # 4. Return (subtotal - discount + delivery)
  #
  # @return [Float] the total price rounded to 2 decimal places
  #
  # @example
  #   basket.add('R01')
  #   basket.add('R01')
  #   basket.total #=> 54.37
  def total
    subtotal = calculate_subtotal
    discount = calculate_discount
    delivery = @delivery_calculator.calculate(subtotal - discount)

    final_total = subtotal - discount + delivery
    # Truncate to 2 decimal places (not round) to match financial requirements
    # This ensures we never overcharge the customer by rounding up
    (final_total * 100).truncate / 100.0
  end

  private

  # Calculates the subtotal of all items before discounts and delivery.
  #
  # @return [BigDecimal] the subtotal
  # @api private
  def calculate_subtotal
    @items.sum { |item| item[:product].price * item[:quantity] }
  end

  # Calculates the total discount from all offers.
  #
  # @return [BigDecimal] the total discount amount
  # @api private
  def calculate_discount
    @offers.sum { |offer| offer.apply(@items) }
  end
end
