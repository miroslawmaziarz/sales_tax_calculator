# frozen_string_literal: true

require_relative '../product'
require_relative '../money'

module SalesTaxCalculator
  module Basket
    # Represents a line item in a shopping basket.
    # Combines a product with quantity and pre-calculated tax.
    #
    # @example
    #   product = Product.new(name: "book", price: 12.49, category: :book)
    #   calculator = TaxCalculator.new
    #   item = Item.new(product: product, quantity: 2, calculator: calculator)
    #   item.tax           # => Money (pre-calculated)
    #   item.total_price   # => Money (shelf price + tax)
    #
    class Item
      attr_reader :product, :quantity, :tax, :shelf_price, :total_price

      # @param product [Product] The product being purchased
      # @param quantity [Integer] The quantity being purchased
      # @param calculator [TaxCalculator] Calculator for computing tax
      def initialize(product:, quantity:, calculator:)
        validate_inputs!(product:, quantity:)

        @product = product
        @quantity = quantity

        @shelf_price = product.price * quantity
        @tax = calculator.calculate_for_product(product, quantity)
        @total_price = @shelf_price + @tax
      end

      # Delegates to product for display name
      # @return [String] formatted display name
      def display_name
        product.display_name
      end

      private

      def validate_inputs!(product:, quantity:)
        raise ArgumentError, 'Product cannot be nil' if product.nil?
        raise ArgumentError, 'Quantity must be positive' if quantity.nil? || quantity < 1
      end
    end
  end
end
