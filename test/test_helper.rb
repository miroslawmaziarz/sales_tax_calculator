# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/money'
require_relative '../lib/product'
require_relative '../lib/basket/item'
require_relative '../lib/basket/shopping_basket'
require_relative '../lib/basket/receipt'
require_relative '../lib/tax/rounder'
require_relative '../lib/tax/rules/tax_rule'
require_relative '../lib/tax/rules/basic_sales_tax_rule'
require_relative '../lib/tax/rules/import_duty_rule'
require_relative '../lib/tax/tax_calculator'
require_relative '../lib/parsers/item_parser'

module TestHelpers
  def create_product(
    name: 'test product',
    price: 10.00,
    imported: false,
    category: :general
  )
    SalesTaxCalculator::Product.new(
      name:,
      price:,
      imported:,
      category:
    )
  end

  def create_calculator
    SalesTaxCalculator::Tax::TaxCalculator.new
  end

  def create_basket
    SalesTaxCalculator::Basket::ShoppingBasket.new
  end

  def assert_money(expected_cents, actual_money, message = nil)
    assert_equal expected_cents, actual_money.cents, message
  end

  def assert_money_string(expected_string, actual_money, message = nil)
    assert_equal expected_string, actual_money.to_s, message
  end
end
