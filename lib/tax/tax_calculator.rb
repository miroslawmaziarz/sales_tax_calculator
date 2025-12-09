# frozen_string_literal: true

require_relative '../money'
require_relative 'rounder'
require_relative 'rules/basic_sales_tax_rule'
require_relative 'rules/import_duty_rule'

module SalesTaxCalculator
  module Tax
    # Calculates the total tax for a product by applying all applicable tax rules.
    #
    # Uses integer arithmetic (cents and centicents) to avoid
    # floating-point precision errors.
    #
    # The rounding rule:
    #   1. Calculate raw tax for ONE item in centicents (price_cents × rate)
    #   2. Round UP to the nearest 5 cents
    #   3. Multiply by quantity
    #
    # @example
    #   calculator = TaxCalculator.new
    #   product = Product.new(name: "perfume", price: 11.25, category: :general)
    #   tax = calculator.calculate_for_product(product, 3)
    #
    class TaxCalculator
      # @param rules [Array<TaxRule>] Tax rules to apply (defaults to standard rules)
      # @param rounder [Rounder] Rounder for tax amounts (defaults to standard rounder)
      def initialize(rules: default_rules, rounder: Rounder.new)
        @rules = rules.freeze
        @rounder = rounder
      end

      # Calculates the total tax for a product with quantity.
      #
      # All calculations use integer arithmetic:
      # - Centi-cents (hundredths of a cent) for calculations
      # - Cents for the final result
      #
      # @param product [Product]
      # @param quantity [Integer]
      # @return [Money] The total tax amount
      def calculate_for_product(product, quantity)
        raw_tax_centicents     = @rules.sum { |rule| rule.calculate_centicents_for_unit(product) }
        rounded_tax_centicents = @rounder.round_up_centicents(raw_tax_centicents)

        total_tax_cents = (rounded_tax_centicents / 100) * quantity

        Money.new(total_tax_cents)
      end

      private

      def default_rules
        [BasicSalesTaxRule.new, ImportDutyRule.new]
      end
    end
  end
end
