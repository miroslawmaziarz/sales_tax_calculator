# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Basket
    class ShoppingBasketTest < Minitest::Test
      include TestHelpers

      def setup
        @basket = create_basket
        @book = create_product(name: 'book', price: 12.49, category: :book)
        @cd = create_product(name: 'music CD', price: 14.99, category: :general)
      end

      def test_adds_item_to_basket
        new_basket = @basket.add(@book, quantity: 1)

        assert_equal 1, new_basket.items.length
      end

      def test_add_returns_new_basket
        new_basket = @basket.add(@book)

        refute_same @basket, new_basket
        assert_equal 0, @basket.items.length
        assert_equal 1, new_basket.items.length
      end

      def test_chains_multiple_adds
        basket = @basket
                 .add(@book, quantity: 1)
                 .add(@cd, quantity: 1)

        assert_equal 2, basket.items.length
      end

      def test_calculates_total_tax
        # Book: tax-exempt, tax = $0
        # CD: 10% of $14.99 = $1.499 -> rounds to $1.50
        basket = @basket
                 .add(@book, quantity: 1)
                 .add(@cd, quantity: 1)

        assert_equal 150, basket.total_tax.cents
      end

      def test_calculates_total_price
        # Book: $12.49 + $0 tax = $12.49
        # CD: $14.99 + $1.50 tax = $16.49
        # Total: $28.98
        basket = @basket
                 .add(@book, quantity: 1)
                 .add(@cd, quantity: 1)

        assert_equal 2898, basket.total_price.cents
      end

      def test_handles_quantity_correctly
        # 3 CDs: each has tax of $1.50, total = $4.50
        basket = @basket.add(@cd, quantity: 3)

        assert_equal 450, basket.total_tax.cents
      end

      def test_empty_basket_has_zero_totals
        assert_equal 0, @basket.total_tax.cents
        assert_equal 0, @basket.total_price.cents
      end

      def test_iterates_with_tax_information
        basket = @basket
                 .add(@book, quantity: 1)
                 .add(@cd, quantity: 1)

        items_collected = []
        basket.each_with_tax do |item, tax, price_with_tax|
          items_collected << {
            name: item.display_name,
            tax: tax.cents,
            total: price_with_tax.cents
          }
        end

        assert_equal 2, items_collected.length
        assert_equal 'book', items_collected[0][:name]
        assert_equal 0, items_collected[0][:tax]
        assert_equal 1249, items_collected[0][:total]
      end
    end
  end
end
