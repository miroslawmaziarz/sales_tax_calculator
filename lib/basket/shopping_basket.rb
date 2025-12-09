# frozen_string_literal: true

require_relative '../product'
require_relative 'item'
require_relative '../money'
require_relative '../tax/tax_calculator'

module SalesTaxCalculator
  module Basket
    # Represents a shopping basket containing multiple items.
    #
    # @example
    #   basket = ShoppingBasket.new
    #   product = Product.new(name: "book", price: 12.49, category: :book)
    #   basket = basket.add(product, quantity: 2)
    #   basket.total_tax
    #   basket.total_price
    #
    class ShoppingBasket
      attr_reader :items

      # @param items [Array<Item>] Initial items in the basket
      # @param calculator [Tax::Calculator] Calculator for computing taxes
      def initialize(items: [], calculator: Tax::TaxCalculator.new)
        @items = items.freeze
        @calculator = calculator
      end

      # Returns a new basket with the added product item.
      # Creates an Item from the Product with precalculated tax.
      #
      # @param product [Product] The product to add
      # @param quantity [Integer] The quantity to add (default: 1)
      # @return [ShoppingBasket] A new basket with the item added
      def add(product, quantity: 1)
        item = Item.new(product: product, quantity: quantity, calculator: @calculator)
        self.class.new(items: @items + [item], calculator: @calculator)
      end

      # Calculates the total sales tax for all items.
      #
      # @return [Money] Total tax amount
      def total_tax
        @items.reduce(Money.zero) { |sum, item| sum + item.tax }
      end

      # Calculates the total price including tax for all items.
      # Price is pre-calculated in each Item, so no duplication here.
      #
      # @return [Money] Total price with tax
      def total_price
        @items.reduce(Money.zero) { |sum, item| sum + item.total_price }
      end

      # Returns each item with its calculated tax and final price.
      #
      # @yield [item, tax, price_with_tax] Block to process each item
      # @yieldparam item [Item] The item
      # @yieldparam tax [Money] The tax for this item (pre-calculated)
      # @yieldparam price_with_tax [Money] The price including tax (pre-calculated)
      def each_with_tax
        @items.each do |item|
          yield item, item.tax, item.total_price
        end
      end
    end
  end
end
