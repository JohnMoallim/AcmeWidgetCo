# frozen_string_literal: true

# Value object representing a product with code, name, and price.
#
# Products are immutable once created and use BigDecimal for price
# to ensure precision in financial calculations. Product equality
# is based solely on the product code, allowing products to be used
# as hash keys.
#
# @example Create a product
#   product = Product.new(code: 'R01', name: 'Red Widget', price: 32.95)
#   product.code  #=> "R01"
#   product.price #=> BigDecimal("32.95")
#
class Product
  # @return [String] the product code (uppercase)
  # @return [String] the product name
  # @return [BigDecimal] the product price
  attr_reader :code, :name, :price

  # Creates a new product instance.
  #
  # @param code [String, Symbol] the product code (will be converted to uppercase)
  # @param name [String] the product name
  # @param price [Numeric, String] the product price (will be converted to BigDecimal)
  #
  # @example
  #   product = Product.new(code: 'r01', name: 'Red Widget', price: 32.95)
  #   product.code #=> "R01"
  def initialize(code:, name:, price:)
    @code = code.to_s.upcase
    @name = name
    @price = BigDecimal(price.to_s)
  end

  # Compares products based on their product code.
  #
  # @param other [Object] the object to compare with
  # @return [Boolean] true if both are Products with the same code
  def ==(other)
    other.is_a?(Product) && code == other.code
  end

  # Checks equality for hash key usage.
  #
  # @param other [Object] the object to compare with
  # @return [Boolean] true if both are equal
  def eql?(other)
    self == other
  end

  # Generates hash code for use in hashes and sets.
  #
  # @return [Integer] the hash code based on product code
  def hash
    code.hash
  end
end
