# frozen_string_literal: true

require 'bigdecimal'

# Calculator for determining delivery charges based on order amount.
#
# Uses a threshold-based rule system where delivery charges decrease
# as the order total increases. Rules are evaluated in descending order
# by threshold amount.
#
# @example Calculate delivery charges
#   rules = DeliveryChargeRules.default
#   calculator = DeliveryChargeCalculator.new(rules)
#
#   calculator.calculate(BigDecimal('45.00'))  #=> BigDecimal('4.95')
#   calculator.calculate(BigDecimal('75.00'))  #=> BigDecimal('2.95')
#   calculator.calculate(BigDecimal('95.00'))  #=> BigDecimal('0')
#
class DeliveryChargeCalculator
  # Creates a new delivery charge calculator.
  #
  # @param rules [DeliveryChargeRules] the delivery charge rules to apply
  #
  # @example
  #   calculator = DeliveryChargeCalculator.new(DeliveryChargeRules.default)
  def initialize(rules)
    @rules = rules
  end

  # Calculates the delivery charge for a given subtotal.
  #
  # @param subtotal [BigDecimal] the order subtotal amount
  # @return [BigDecimal] the delivery charge
  #
  # @example
  #   calculator.calculate(BigDecimal('45.00')) #=> BigDecimal('4.95')
  def calculate(subtotal)
    BigDecimal(charge_for_amount(subtotal).to_s)
  end

  private

  # Finds the appropriate charge for an amount based on rules.
  #
  # @param amount [BigDecimal] the amount to evaluate
  # @return [Numeric] the delivery charge
  # @api private
  def charge_for_amount(amount)
    rule = @rules.rules.find { |r| amount >= r[:threshold] }
    rule ? rule[:charge] : @rules.rules.last[:charge]
  end
end
