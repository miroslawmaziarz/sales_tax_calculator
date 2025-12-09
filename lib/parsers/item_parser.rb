# frozen_string_literal: true

require_relative '../product'

module SalesTaxCalculator
  module Parsers
    # Parses text input into Product objects with quantity.
    # Handles common input formats for shopping items.
    # Returns a struct with product and quantity.
    #
    # @example
    #   parser = ItemParser.new
    #   result = parser.parse("1 book at 12.49")
    #   result.product  # => Product
    #   result.quantity # => 1
    #
    class ItemParser
      # Regular expression to match input format:
      # "quantity name at price" or "quantity imported name at price"
      INPUT_PATTERN = /\A(\d+)\s+(.+)\s+at\s+(\d+\.\d{2})\z/i

      BOOK_KEYWORDS = %w[book].freeze
      FOOD_KEYWORDS = %w[chocolate chocolates candy food].freeze
      MEDICAL_KEYWORDS = %w[pills headache medicine medical].freeze

      ProductWithQuantity = Struct.new(:product, :quantity)

      # Parses a single line of input into a Product with quantity.
      #
      # @param line [String] The input line to parse
      # @return [ProductWithQuantity] The parsed product with quantity
      # @raise [ArgumentError] If the input format is invalid
      def parse(line)
        match = INPUT_PATTERN.match(line.strip)
        raise ArgumentError, "Invalid input format: #{line}" unless match

        quantity = match[1].to_i
        name = match[2].strip
        price = match[3]

        imported = name.include?('imported')
        clean_name = name.gsub(/\bimported\s*/i, '').strip
        category = detect_category(clean_name)

        product = Product.new(
          name: clean_name,
          price:,
          imported:,
          category:
        )

        ProductWithQuantity.new(product, quantity)
      end

      # Parses multiple lines into an array of Products with quantities.
      #
      # @param text [String] Multi-line text input
      # @return [Array<ProductWithQuantity>] Array of parsed products with quantities
      def parse_all(text)
        text.lines
            .map(&:strip)
            .reject(&:empty?)
            .map { |line| parse(line) }
      end

      private

      def detect_category(name)
        lower_name = name.downcase

        return :book if BOOK_KEYWORDS.any? { |keyword| lower_name.include?(keyword) }
        return :food if FOOD_KEYWORDS.any? { |keyword| lower_name.include?(keyword) }
        return :medical if MEDICAL_KEYWORDS.any? { |keyword| lower_name.include?(keyword) }

        :general
      end
    end
  end
end
