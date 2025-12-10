# frozen_string_literal: true

require_relative 'money'
require_relative 'product'
require_relative 'basket/item'
require_relative 'tax/rules/tax_rule'
require_relative 'tax/rules/basic_sales_tax_rule'
require_relative 'tax/rules/import_duty_rule'
require_relative 'tax/tax_calculator'
require_relative 'basket/shopping_basket'
require_relative 'basket/receipt'
require_relative 'parsers/item_parser'

# Main module for the Sales Tax Calculator.
#
# @example Basic usage
#   basket = SalesTaxCalculator::Basket::Basket.new
#   product = SalesTaxCalculator::Product.new(name: "book", price: 12.49, category: :book)
#   basket = basket.add(product, quantity: 1)
#   receipt = SalesTaxCalculator::Basket::Receipt.new(basket)
#   puts receipt.to_s
#
# @example Using the parser
#   parser = SalesTaxCalculator::Parsers::ItemParser.new
#   basket = SalesTaxCalculator::Basket::Basket.new
#   parsed = parser.parse("1 book at 12.49")
#   basket = basket.add(parsed.product, quantity: parsed.quantity)
#   receipt = SalesTaxCalculator::Basket::Receipt.new(basket)
#   puts receipt.to_s
#
module SalesTaxCalculator
end
