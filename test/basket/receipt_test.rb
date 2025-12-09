# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Basket
    class ReceiptTest < Minitest::Test
      include TestHelpers

      def test_generates_receipt_with_correct_format
        book = create_product(name: 'book', price: 12.49, category: :book)
        cd = create_product(name: 'music CD', price: 14.99, category: :general)

        basket = create_basket
                 .add(book, quantity: 1)
                 .add(cd, quantity: 1)

        receipt = Receipt.new(basket)
        output = receipt.to_s

        # Should contain line items
        assert_match(/1 book: 12\.49/, output)
        assert_match(/1 music CD: 16\.49/, output) # $14.99 + $1.50 tax

        # Should contain totals
        assert_match(/Sales Taxes: 1\.50/, output)
        assert_match(/Total: 28\.98/, output)
      end

      def test_displays_imported_prefix
        perfume = create_product(name: 'bottle of perfume', price: 27.99, imported: true, category: :general)
        basket = create_basket.add(perfume, quantity: 1)

        receipt = Receipt.new(basket)
        output = receipt.to_s

        assert_match(/imported bottle of perfume/, output)
      end

      def test_displays_quantity_in_receipt
        cd = create_product(name: 'music CD', price: 14.99, category: :general)
        basket = create_basket.add(cd, quantity: 3)

        receipt = Receipt.new(basket)
        output = receipt.to_s

        assert_match(/3 music CD:/, output)
      end

      def test_handles_empty_basket
        receipt = Receipt.new(create_basket)
        output = receipt.to_s

        assert_match(/Sales Taxes: 0\.00/, output)
        assert_match(/Total: 0\.00/, output)
      end
    end
  end
end
