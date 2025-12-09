# frozen_string_literal: true

module SalesTaxCalculator
  module Tax
    # Value object responsible for rounding tax amounts.
    # Implements the receipt tax rounding rule: round UP to the nearest $0.05.
    #
    # Uses integer arithmetic exclusively to avoid floating-point precision errors.
    # Input is in "centi-cents" (hundredths of a cent) to preserve precision
    # during intermediate calculations.
    #
    # This is extracted as a separate class following DDD principles:
    # - Single Responsibility: only handles the rounding concern
    # - Explicit Domain Concept: rounding rules are a business rule
    # - Testable in isolation
    #
    # @example
    #   rounder = Rounder.new
    #   rounder.round_up_centicents(5625)  # => 60 cents (56.25 cents rounds to 60)
    #   rounder.round_up_centicents(5000)  # => 50 cents (already a multiple of 5)
    #   rounder.round_up_centicents(10)    # => 5 cents  (0.10 cents rounds up)
    #
    class Rounder
      INCREMENT_CENTICENTS = 500

      # Rounds a value up to the nearest 5 cents.
      # Returns the result in centicents
      #
      # @param centicents [Integer] The amount in centi-cents
      # @return [Integer] The rounded amount in centi-cents
      #
      # @example
      #   round_up_centicents(11250)  # => 115 cents ($1.15) - 112.50 cents rounds up
      #   round_up_centicents(5000)   # => 50 cents ($0.50) - already multiple of 5
      #   round_up_centicents(1)      # => 5 cents ($0.05) - any fraction rounds up
      #
      def round_up_centicents(centicents)
        return 0 if centicents.zero?

        remainder = centicents % INCREMENT_CENTICENTS

        return centicents if remainder.zero?

        centicents + (INCREMENT_CENTICENTS - remainder)
      end
    end
  end
end
