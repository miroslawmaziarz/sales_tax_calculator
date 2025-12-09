# frozen_string_literal: true

require_relative 'money'

module SalesTaxCalculator
  # Represents a product from the catalog with its properties.
  #
  # @example
  #   product = Product.new(
  #     name: "bottle of perfume",
  #     price: 27.99,
  #     imported: true,
  #     category: :general
  #   )
  #
  class Product
    EXEMPT_CATEGORIES = %i[book food medical].freeze
    VALID_CATEGORIES = %i[book food medical general].freeze

    attr_reader :name, :price, :category

    # @param name [String] The name of the product
    # @param price [Numeric] The shelf price of the product (before tax)
    # @param imported [Boolean] Whether the product is imported
    # @param category [Symbol] The category (:book, :food, :medical, :general)
    def initialize(name:, price:, imported: false, category: :general)
      validate_inputs!(name:, price:, category:)

      @name = name.freeze
      @price = Money.from_amount(price)
      @imported = imported
      @category = category
    end

    def imported?
      @imported
    end

    def tax_exempt?
      EXEMPT_CATEGORIES.include?(@category)
    end

    # @return [String] formatted display name including import status
    def display_name
      prefix = imported? ? 'imported ' : ''
      "#{prefix}#{@name}"
    end

    private

    def validate_inputs!(name:, price:, category:)
      raise ArgumentError, 'Name cannot be empty' if name.nil? || name.strip.empty?
      raise ArgumentError, 'Price must be positive' if price.nil? || price.to_f.negative?
      raise ArgumentError, "Invalid category: #{category}" unless VALID_CATEGORIES.include?(category)
    end
  end
end
