# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Parsers
    class ItemParserTest < Minitest::Test
      include TestHelpers

      def setup
        @parser = ItemParser.new
      end

      def test_parses_simple_input
        result = @parser.parse('1 book at 12.49')

        assert_equal 1, result.quantity
        assert_equal 'book', result.product.name
        assert_equal 1249, result.product.price.cents
        refute result.product.imported?
      end

      def test_parses_imported_product
        result = @parser.parse('1 imported bottle of perfume at 27.99')

        assert result.product.imported?
        assert_equal 'bottle of perfume', result.product.name
      end

      def test_parses_quantity_correctly
        result = @parser.parse('3 chocolate bars at 0.85')

        assert_equal 3, result.quantity
      end

      def test_detects_book_category
        result = @parser.parse('1 book at 12.49')

        assert_equal :book, result.product.category
      end

      def test_detects_food_category
        assert_equal :food, @parser.parse('1 chocolate bar at 0.85').product.category
        assert_equal :food, @parser.parse('1 box of chocolates at 10.00').product.category
      end

      def test_detects_medical_category
        assert_equal :medical, @parser.parse('1 packet of headache pills at 9.75').product.category
      end

      def test_defaults_to_general_category
        result = @parser.parse('1 bottle of perfume at 18.99')

        assert_equal :general, result.product.category
      end

      def test_parses_multiple_lines
        input = <<~INPUT
          1 book at 12.49
          1 music CD at 14.99
          1 chocolate bar at 0.85
        INPUT

        results = @parser.parse_all(input)

        assert_equal 3, results.length
        assert_equal 'book', results[0].product.name
        assert_equal 'music CD', results[1].product.name
        assert_equal 'chocolate bar', results[2].product.name
      end

      def test_raises_error_for_invalid_format
        assert_raises(ArgumentError) do
          @parser.parse('invalid input')
        end
      end

      def test_ignores_empty_lines
        input = "1 book at 12.49\n\n1 music CD at 14.99\n"

        results = @parser.parse_all(input)

        assert_equal 2, results.length
      end
    end
  end
end
