# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Tax
    class BasicSalesTaxRuleTest < Minitest::Test
      include TestHelpers

      def setup
        @rule = BasicSalesTaxRule.new
      end

      def test_has_correct_rate
        assert_equal 10, @rule.rate_percent
      end

      def test_applies_to_general_category
        product = create_product(category: :general)

        assert @rule.applicable?(product)
      end

      def test_does_not_apply_to_exempt_categories
        refute @rule.applicable?(create_product(category: :book))
        refute @rule.applicable?(create_product(category: :food))
        refute @rule.applicable?(create_product(category: :medical))
      end

      def test_calculates_tax_in_centicents
        product = create_product(price: 11.25, category: :general)

        # 1125 cents * 10 = 11250 centicents (112.5 cents)
        assert_equal 11_250, @rule.calculate_centicents_for_unit(product)
      end

      def test_returns_zero_for_exempt_products
        product = create_product(category: :book)

        assert_equal 0, @rule.calculate_centicents_for_unit(product)
      end
    end
  end
end
