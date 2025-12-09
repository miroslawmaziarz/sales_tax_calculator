# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Tax
    class ImportDutyRuleTest < Minitest::Test
      include TestHelpers

      def setup
        @rule = ImportDutyRule.new
      end

      def test_has_correct_rate
        assert_equal 5, @rule.rate_percent
      end

      def test_applies_to_imported_products
        product = create_product(imported: true)

        assert @rule.applicable?(product)
      end

      def test_does_not_apply_to_non_imported_products
        product = create_product(imported: false)

        refute @rule.applicable?(product)
      end

      def test_applies_to_imported_food
        product = create_product(imported: true, category: :food)

        assert @rule.applicable?(product)
      end

      def test_calculates_tax_in_centicents
        product = create_product(price: 10.00, imported: true)

        # 1000 cents * 5 = 5000 centicents (50 cents)
        assert_equal 5_000, @rule.calculate_centicents_for_unit(product)
      end

      def test_returns_zero_for_non_imported_products
        product = create_product(imported: false)

        assert_equal 0, @rule.calculate_centicents_for_unit(product)
      end
    end
  end
end
