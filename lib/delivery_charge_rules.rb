# frozen_string_literal: true

# Configuration object for delivery charge rules.
#
# Stores threshold-based rules for calculating delivery charges.
# Rules are automatically sorted by threshold in descending order
# to ensure correct evaluation.
#
# @example Create custom rules
#   rules = DeliveryChargeRules.new([
#     { threshold: 100, charge: 0 },
#     { threshold: 50, charge: 3.95 },
#     { threshold: 0, charge: 5.95 }
#   ])
#
# @example Use default rules
#   rules = DeliveryChargeRules.default
#
class DeliveryChargeRules
  # @return [Array<Hash>] the delivery charge rules sorted by threshold descending
  attr_reader :rules

  # Creates new delivery charge rules.
  #
  # Rules are automatically sorted by threshold in descending order.
  #
  # @param rules [Array<Hash>] array of rule hashes with :threshold and :charge keys
  #
  # @example
  #   rules = DeliveryChargeRules.new([
  #     { threshold: 0, charge: 4.95 },
  #     { threshold: 50, charge: 2.95 }
  #   ])
  def initialize(rules = [])
    @rules = rules.sort_by { |rule| -rule[:threshold] }
  end

  # Returns the default delivery charge rules for Acme Widget Co.
  #
  # Default rules:
  # - Orders under $50: $4.95 delivery
  # - Orders $50-$89.99: $2.95 delivery
  # - Orders $90+: Free delivery
  #
  # @return [DeliveryChargeRules] the default rules
  #
  # @example
  #   rules = DeliveryChargeRules.default
  def self.default
    new([
          { threshold: 90, charge: 0 },
          { threshold: 50, charge: 2.95 },
          { threshold: 0, charge: 4.95 }
        ])
  end
end
