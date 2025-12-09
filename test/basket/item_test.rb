# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Basket
    class ItemTest < Minitest::Test
      include TestHelpers

      def setup
        @product = create_product(name: 'perfume', price: 18.99, category: :general)
        @calculator = create_calculator
      end

      def test_creates_item_with_precalculated_tax
        item = Item.new(product: @product, quantity: 1, calculator: @calculator)

        # Tax: 10% of 18.99 = 1.899 -> rounds to 1.90
        assert_equal 190, item.tax.cents
      end

      def test_calculates_shelf_price
        item = Item.new(product: @product, quantity: 2, calculator: @calculator)

        # 2 × $18.99 = $37.98
        assert_equal 3798, item.shelf_price.cents
      end

      def test_calculates_total_price
        item = Item.new(product: @product, quantity: 2, calculator: @calculator)

        # Shelf: 2 × $18.99 = $37.98
        # Tax: 2 × $1.90 = $3.80
        # Total: $41.78
        assert_equal 4178, item.total_price.cents
      end

      def test_validates_product_presence
        assert_raises(ArgumentError) do
          Item.new(product: nil, quantity: 1, calculator: @calculator)
        end
      end

      def test_validates_positive_quantity
        assert_raises(ArgumentError) do
          Item.new(product: @product, quantity: 0, calculator: @calculator)
        end
      end

      def test_delegates_display_name
        product = create_product(name: 'perfume', imported: true)
        item = Item.new(product: product, quantity: 1, calculator: @calculator)

        assert_equal 'imported perfume', item.display_name
      end
    end
  end
end
