# frozen_string_literal: true

require_relative 'shopping_basket'

module SalesTaxCalculator
  module Basket
    # Generates a formatted receipt for a shopping basket.
    #
    # @example
    #   receipt = Receipt.new(basket)
    #   puts receipt.to_s
    #
    class Receipt
      # @param basket [ShoppingBasket] The basket to generate receipt for
      def initialize(basket)
        @basket = basket
      end

      # Generates the formatted receipt string.
      #
      # @return [String] The formatted receipt
      def to_s
        lines = []

        @basket.each_with_tax do |item, _tax, price_with_tax|
          lines << format_line_item(item, price_with_tax)
        end

        lines << format_sales_taxes(@basket.total_tax)
        lines << format_total(@basket.total_price)

        lines.join("\n")
      end

      private

      def format_line_item(item, price)
        "#{item.quantity} #{item.display_name}: #{price}"
      end

      def format_sales_taxes(amount)
        "Sales Taxes: #{amount}"
      end

      def format_total(amount)
        "Total: #{amount}"
      end
    end
  end
end
