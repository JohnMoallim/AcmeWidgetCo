# frozen_string_literal: true

require_relative 'product'

# Product catalog for managing and looking up products.
#
# Provides O(1) lookup by product code using a hash-based internal structure.
# Product codes are case-insensitive.
#
# @example Create and use a catalog
#   catalog = ProductCatalog.new([
#     Product.new(code: 'R01', name: 'Red Widget', price: 32.95),
#     Product.new(code: 'G01', name: 'Green Widget', price: 24.95)
#   ])
#
#   catalog.find('r01') #=> Product<R01>
#   catalog.all.size    #=> 2
#
class ProductCatalog
  # Creates a new product catalog.
  #
  # @param products [Array<Product>] the products to include in the catalog
  #
  # @example
  #   catalog = ProductCatalog.new([product1, product2])
  def initialize(products = [])
    @products = products.each_with_object({}) do |product, hash|
      hash[product.code] = product
    end
  end

  # Finds a product by its code.
  #
  # Product codes are case-insensitive.
  #
  # @param code [String, Symbol] the product code to search for
  # @return [Product, nil] the product if found, nil otherwise
  #
  # @example
  #   catalog.find('R01')  #=> Product<R01>
  #   catalog.find('r01')  #=> Product<R01> (case-insensitive)
  #   catalog.find('INVALID') #=> nil
  def find(code)
    @products[code.to_s.upcase]
  end

  # Returns all products in the catalog.
  #
  # @return [Array<Product>] all products
  #
  # @example
  #   catalog.all #=> [Product<R01>, Product<G01>]
  def all
    @products.values
  end
end
