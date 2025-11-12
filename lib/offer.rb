# frozen_string_literal: true

# Base class for special offer implementations using the Strategy pattern.
#
# Concrete offer classes should inherit from this class and implement
# the #apply method to calculate discounts based on basket items.
#
# @abstract Subclasses must implement {#apply}
#
# @example Implementing a custom offer
#   class BuyTwoGetOneFree < Offer
#     def initialize(product_code:)
#       @product_code = product_code
#     end
#
#     def apply(items)
#       # Calculate discount logic here
#     end
#   end
#
class Offer
  # Applies the offer to a collection of basket items.
  #
  # @abstract Subclasses must implement this method
  #
  # @param items [Array<Hash>] array of item hashes with :product and :quantity keys
  # @return [BigDecimal] the discount amount to apply
  #
  # @raise [NotImplementedError] if not implemented by subclass
  def apply(items)
    raise NotImplementedError, "#{self.class} must implement #apply"
  end

  protected

  # Helper method to count items with a specific product code.
  #
  # @param items [Array<Hash>] array of item hashes
  # @param code [String] the product code to count
  # @return [Integer] the count of matching items
  #
  # @api private
  def count_items_by_code(items, code)
    items.count { |item| item[:product].code == code }
  end
end
