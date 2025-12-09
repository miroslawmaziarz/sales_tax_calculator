# frozen_string_literal: true

module SalesTaxCalculator
  # Simple value object for amounts using fixed-point arithmetic.
  # Stores values in cents (integer) to avoid floating-point issues.
  #
  # @example
  #   price = Money.from_amount(12.49)  # => 1249 cents
  #   price.cents                       # => 1249
  #   price.to_s                        # => "12.49"
  #
  class Money
    class NegativeAmountError < StandardError; end
    class InvalidAmountError < StandardError; end

    attr_reader :cents

    # Creates a Money object from cents (integer).
    #
    # @param cents [Integer] Amount in cents
    def initialize(cents)
      @cents = cents.to_i
    end

    # Creates a Money object from a decimal amount.
    #
    # @param amount [Numeric, String] Amount in dollars (e.g., 12.49)
    # @return [Money]
    # @raise [InvalidAmountError] if amount has more than 2 decimal places
    def self.from_amount(amount)
      amount_float = amount.to_f

      raise NegativeAmountError, 'Amount must be positive' if amount_float.negative?

      # TODO: are there more optimal approach to check if the amount has more than 2 decimal places?
      # Check if the amount has more than 2 decimal places
      # if (cents % 100) != 0
      #  raise InvalidAmountError, 'Amount cannot have more than 2 decimal places'
      # end

      new((amount_float * 100).round)
    end

    ZERO = new(0)

    # @return [Money] A zero Money object
    def self.zero
      ZERO
    end

    # Adds two Money objects.
    #
    # @param other [Money]
    # @return [Money]
    def +(other)
      Money.new(@cents + other.cents)
    end

    # Multiplies by a scalar.
    #
    # @param scalar [Numeric]
    # @return [Money]
    def *(other)
      Money.new((@cents * other).to_i)
    end

    # Formats as currency string (e.g., "12.49").
    #
    # @return [String]
    def to_s
      format('%<dollars>d.%<cents>02d', dollars: @cents / 100, cents: @cents % 100)
    end
  end
end
