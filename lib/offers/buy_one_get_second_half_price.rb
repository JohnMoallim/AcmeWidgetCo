# frozen_string_literal: true

require_relative '../offer'

# "Buy one, get second half price" special offer implementation.
#
# Applies a 50% discount to every second item of a specific product code
# in the basket. For example, with 4 red widgets, items 2 and 4 receive
# the discount.
#
# @example Create and apply the offer
#   offer = BuyOneGetSecondHalfPrice.new(product_code: 'R01')
#   items = [
#     { product: red_widget, quantity: 1 },
#     { product: red_widget, quantity: 1 }
#   ]
#   offer.apply(items) #=> BigDecimal('16.475') # Half of 32.95
#
class BuyOneGetSecondHalfPrice < Offer
  # Creates a new buy-one-get-second-half-price offer.
  #
  # @param product_code [String, Symbol] the product code to apply the offer to
  #
  # @example
  #   offer = BuyOneGetSecondHalfPrice.new(product_code: 'R01')
  def initialize(product_code:)
    @product_code = product_code.to_s.upcase
  end

  # Applies the offer to calculate discount amount.
  #
  # Every second matching item receives a 50% discount.
  # For example: 1st item full price, 2nd item half price,
  # 3rd item full price, 4th item half price, etc.
  #
  # @param items [Array<Hash>] array of item hashes with :product and :quantity keys
  # @return [BigDecimal] the total discount amount
  #
  # @example
  #   offer.apply([red_widget, red_widget]) #=> discount for 2nd widget
  def apply(items)
    discount = BigDecimal('0')
    matching_items = items.select { |item| item[:product].code == @product_code }

    return discount if matching_items.empty?

    # Apply discount to every second item (2nd, 4th, 6th, etc.)
    matching_items.each_with_index do |item, index|
      next unless (index + 1).even?

      discount += item[:product].price / 2
    end

    discount
  end
end
