# Acme Widget Co - Shopping Basket

A Ruby implementation of a shopping basket system with delivery charge rules and special offers.

## Overview

This is a proof-of-concept shopping basket system that calculates order totals with:
- Product pricing
- Delivery charges based on order total
- Special offers (buy one get second half price)

The implementation uses Ruby stdlib with no external runtime dependencies, following SOLID principles and the Strategy pattern for extensibility.

## Products

| Product Code | Name         | Price  |
|-------------|--------------|--------|
| R01         | Red Widget   | $32.95 |
| G01         | Green Widget | $24.95 |
| B01         | Blue Widget  | $7.95  |

## Delivery Charges

| Order Total | Delivery Cost |
|------------|---------------|
| < $50      | $4.95        |
| $50 - $89  | $2.95        |
| >= $90     | FREE         |

## Special Offers

**Red Widget Offer**: Buy one red widget, get the second at half price. This applies to every second red widget (e.g., if you buy 4 red widgets, the 2nd and 4th are half price).

## Installation

Requirements:
- Ruby 3.0 or higher
- Bundler

```bash
bundle install
```

## Usage

Run the example scenarios:

```bash
ruby run_examples.rb
```

Expected output:
```
B01, G01: $37.85
R01, R01: $54.37
R01, G01: $60.85
B01, B01, R01, R01, R01: $98.27
```

## Code Example

```ruby
require_relative 'lib/basket'

# Setup catalog
catalog = ProductCatalog.new([
  Product.new(code: 'R01', name: 'Red Widget', price: 32.95),
  Product.new(code: 'G01', name: 'Green Widget', price: 24.95),
  Product.new(code: 'B01', name: 'Blue Widget', price: 7.95)
])

# Setup delivery calculator
delivery_rules = DeliveryChargeRules.default
delivery_calculator = DeliveryChargeCalculator.new(delivery_rules)

# Setup offers
offers = [BuyOneGetSecondHalfPrice.new(product_code: 'R01')]

# Create basket
basket = Basket.new(
  catalog: catalog,
  delivery_calculator: delivery_calculator,
  offers: offers
)

# Add items and calculate total
basket.add('R01')
basket.add('R01')
puts basket.total  # => 54.37
```

## Testing

Run the test suite:

```bash
bundle exec rspec
```

The project has 100% test coverage. To see coverage report:

```bash
bundle exec rake coverage
```

Run code quality checks:

```bash
bundle exec rubocop
bundle exec rake quality  # runs both tests and linting
```

## Architecture

The implementation follows these design principles:

**Separation of Concerns**: Each class has a single responsibility
- `Basket` - orchestrates the basket operations
- `Product` - represents a product (value object)
- `ProductCatalog` - manages product lookup
- `DeliveryChargeCalculator` - calculates delivery charges
- `Offer` - base class for special offers (Strategy pattern)

**Strategy Pattern**: Offers are implemented as strategies, making it easy to add new offer types without modifying existing code.

**Dependency Injection**: The Basket class accepts its dependencies (catalog, delivery calculator, offers) through the constructor, improving testability and flexibility.

**BigDecimal for Money**: All monetary calculations use BigDecimal to avoid floating-point precision issues.

## Design Decisions

### BigDecimal for Pricing
Using BigDecimal instead of Float to prevent precision errors in financial calculations. For example, `0.1 + 0.2 == 0.3` evaluates to false with floats due to binary representation issues.

### Truncation vs Rounding
The final total is truncated to 2 decimal places rather than rounded, ensuring customers are never overcharged by a rounding error.

### Offer Application Order
Discounts are applied before delivery charges are calculated. This means delivery charges are based on the discounted subtotal, which is more customer-friendly.

### Extensibility
New offer types can be added by extending the `Offer` base class:

```ruby
class BuyTwoGetOneFree < Offer
  def initialize(product_code:)
    @product_code = product_code.to_s.upcase
  end

  def apply(items)
    matching = items.select { |item| item[:product].code == @product_code }
    sets_of_three = matching.size / 3
    BigDecimal(sets_of_three) * matching.first[:product].price
  end
end
```

## Assumptions

1. **Pricing Precision**: Using BigDecimal for all monetary calculations to avoid floating-point precision issues.

2. **Offer Application**: The "buy one red widget, get second half price" offer applies to every second red widget in the basket (positions 2, 4, 6, etc.). With 3 red widgets, only the 2nd gets the discount. With 4 red widgets, the 2nd and 4th get discounts.

3. **Delivery Calculation**: Delivery charges are calculated on the subtotal after discounts are applied, not on the original item total.

4. **Product Codes**: Product codes are case-insensitive. The system normalizes them to uppercase internally, so 'r01', 'R01', and 'R01' all refer to the same product.

5. **Multiple Offers**: If multiple offers apply to the same basket, all applicable discounts are summed together.

6. **Quantity**: Each call to `basket.add()` adds a single item. To add multiple items of the same product, call `add()` multiple times.

7. **Invalid Products**: Adding a non-existent product code raises an error rather than silently failing.

## Project Structure

```
lib/
├── basket.rb                    # Main basket class
├── product.rb                   # Product value object
├── product_catalog.rb           # Product lookup
├── delivery_charge_calculator.rb
├── delivery_charge_rules.rb
├── offer.rb                     # Base offer class
└── offers/
    └── buy_one_get_second_half_price.rb

spec/
├── basket_spec.rb
├── product_spec.rb
├── product_catalog_spec.rb
├── delivery_charge_calculator_spec.rb
├── delivery_charge_rules_spec.rb
├── offer_spec.rb
└── offers/
    └── buy_one_get_second_half_price_spec.rb
```

## Rake Tasks

```bash
rake spec       # Run tests
rake rubocop    # Run linter
rake quality    # Run tests and linter
rake coverage   # Run tests with coverage report
rake examples   # Run example scenarios
```
