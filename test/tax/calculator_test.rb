# frozen_string_literal: true

require_relative '../test_helper'

class TaxCalculatorTest < Minitest::Test
  include TestHelpers
  def setup
    @calculator = SalesTaxCalculator::Tax::TaxCalculator.new
  end

  # Test calculate_for_product method

  def test_calculates_tax_by_rounding_each_item_independently_then_multiplying_by_quantity
    # With 10% tax (basic sales tax):
    # Tax per item: (10 × 11.25) / 100 = 1.125 cents = 112.5 cents
    # Rounded up to nearest $0.05: 115 cents = $1.15
    # Tax for 3 items: $1.15 × 3 = $3.45
    product = SalesTaxCalculator::Product.new(
      name: 'box of chocolates',
      price: 11.25,
      imported: false,
      category: :general # 10% basic sales tax applies
    )

    tax = @calculator.calculate_for_product(product, 3)

    assert_equal '3.45', tax.to_s
    assert_equal 345, tax.cents
  end

  def test_rounds_up_per_item_not_on_the_total
    # Calculate what we'd get if rounding on total (incorrect way):
    # Total shelf price: $11.25 × 3 = $33.75
    # Tax on total: (10 × 3375 cents) / 100 = 337.5 cents
    # Rounded up: 340 cents = $3.40
    incorrect_total = 340

    # Calculate correct way (per item):
    # Tax per item: (10 × 1125 cents) / 100 = 112.5 cents
    # Rounded per item: 115 cents
    # Total tax: 115 × 3 = 345 cents = $3.45
    correct_total = 345

    product = SalesTaxCalculator::Product.new(
      name: 'box of chocolates',
      price: 11.25,
      imported: false,
      category: :general
    )

    tax = @calculator.calculate_for_product(product, 3)

    assert_equal correct_total, tax.cents
    refute_equal incorrect_total, tax.cents
  end

  def test_applies_both_basic_sales_tax_and_import_duty_rounding_per_item
    # Tax per item: (15 × 2799 cents) / 100 = 419.85 cents
    # Rounded up to nearest $0.05 (5 cents): 420 cents = $4.20
    # For 2 items: $4.20 × 2 = $8.40
    imported_product = SalesTaxCalculator::Product.new(
      name: 'bottle of perfume',
      price: 27.99,
      imported: true,
      category: :general # Both 10% basic + 5% import = 15% total
    )

    tax = @calculator.calculate_for_product(imported_product, 2)

    assert_equal 840, tax.cents
    assert_equal '8.40', tax.to_s
  end

  def test_calculates_zero_tax_for_exempt_products
    book = SalesTaxCalculator::Product.new(
      name: 'book',
      price: 12.49,
      imported: false,
      category: :book # Tax exempt
    )

    tax = @calculator.calculate_for_product(book, 1)

    assert_equal 0, tax.cents
    assert_equal '0.00', tax.to_s
  end

  def test_applies_only_import_duty_for_imported_tax_exempt_product
    # Tax per item: (5 × 1000 cents) / 100 = 50 cents
    # Already a multiple of 5, no rounding needed
    # For 1 item: $0.50
    imported_chocolates = SalesTaxCalculator::Product.new(
      name: 'box of imported chocolates',
      price: 10.00,
      imported: true,
      category: :food # Exempt from basic tax, but import duty applies
    )

    tax = @calculator.calculate_for_product(imported_chocolates, 1)

    assert_equal 50, tax.cents
    assert_equal '0.50', tax.to_s
  end

  # Rounding behavior tests

  def test_rounds_up_values_that_are_not_multiples_of_5_cents
    # Tax per item: (10 × 99 cents) / 100 = 9.9 cents
    # Rounded up to nearest $0.05: 10 cents
    product = SalesTaxCalculator::Product.new(
      name: 'test product',
      price: 0.99,
      imported: false,
      category: :general # 10% tax
    )

    tax = @calculator.calculate_for_product(product, 1)

    assert_equal 10, tax.cents
  end

  def test_does_not_round_values_that_are_already_multiples_of_5_cents
    product_exact = SalesTaxCalculator::Product.new(
      name: 'test product',
      price: 1.00,
      imported: false,
      category: :general # 10% tax
    )

    # Tax per item: (10 × 100 cents) / 100 = 10 cents
    # Already multiple of 5, no rounding needed
    tax = @calculator.calculate_for_product(product_exact, 1)

    assert_equal 10, tax.cents
  end

  def test_always_rounds_up_never_down
    product_minimal = SalesTaxCalculator::Product.new(
      name: 'test product',
      price: 0.01,
      imported: false,
      category: :general # 10% tax
    )

    # Tax per item: (10 × 1 cent) / 100 = 0.1 cents
    # Rounded up to nearest $0.05: 5 cents
    tax = @calculator.calculate_for_product(product_minimal, 1)

    assert_equal 5, tax.cents
  end

  # Multiple items tests

  def test_demonstrates_the_difference_between_per_item_and_total_rounding
    # Per-item rounding (CORRECT):
    # Tax per item: (10 × 1499 cents) / 100 = 149.9 cents
    # Rounded per item: 150 cents
    # Total tax for 5 items: 150 × 5 = 750 cents = $7.50

    # Total rounding (INCORRECT):
    # Total price: $14.99 × 5 = $74.95 = 7495 cents
    # Tax on total: (10 × 7495) / 100 = 749.5 cents
    # Rounded once: 750 cents = $7.50

    # In this case they happen to be the same, but the logic is different
    product = SalesTaxCalculator::Product.new(
      name: 'music CD',
      price: 14.99,
      imported: false,
      category: :general # 10% tax
    )

    tax = @calculator.calculate_for_product(product, 5)

    assert_equal 750, tax.cents
  end

  def test_shows_case_where_per_item_rounding_yields_higher_tax
    # Using price where per-item rounding makes a difference
    product_diff = SalesTaxCalculator::Product.new(
      name: 'item',
      price: 0.52,
      imported: false,
      category: :general # 10% tax
    )

    # Per-item rounding (CORRECT):
    # Tax per item: (10 × 52 cents) / 100 = 5.2 cents
    # Rounded per item: 10 cents
    # Total tax for 3 items: 10 × 3 = 30 cents

    # Total rounding (INCORRECT):
    # Total price: $0.52 × 3 = $1.56 = 156 cents
    # Tax on total: (10 × 156) / 100 = 15.6 cents
    # Rounded once: 20 cents

    tax = @calculator.calculate_for_product(product_diff, 3)

    # The correct implementation should give us 30 cents (per-item)
    # not 20 cents (total)
    assert_equal 30, tax.cents
  end

  # Edge cases

  def test_handles_quantity_of_1
    product = SalesTaxCalculator::Product.new(
      name: 'test product',
      price: 1.00,
      imported: false,
      category: :general
    )

    tax = @calculator.calculate_for_product(product, 1)

    assert_equal 10, tax.cents # 10% of $1.00 = $0.10
  end

  def test_handles_zero_price
    free_product = SalesTaxCalculator::Product.new(
      name: 'free item',
      price: 0,
      imported: false,
      category: :general
    )

    tax = @calculator.calculate_for_product(free_product, 5)

    assert_equal 0, tax.cents
  end
end
