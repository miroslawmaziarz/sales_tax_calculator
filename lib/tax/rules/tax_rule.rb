# frozen_string_literal: true

require_relative '../../money'

module SalesTaxCalculator
  module Tax
    # Base interface for tax rules.
    #
    # @abstract Subclass and override {#applicable?} and {#rate_percent}
    class TaxRule
      # Determines if this tax rule applies to the given item.
      #
      # @param item [Item] The item to check
      # @return [Boolean] true if this rule applies
      def applicable?(item)
        raise NotImplementedError, "#{self.class} must implement #applicable?"
      end

      # Returns the tax rate as an integer percentage (e.g., 10 for 10%).
      #
      # @return [Integer] The tax rate as percentage
      def rate_percent
        raise NotImplementedError, "#{self.class} must implement #rate_percent"
      end

      # Calculates the raw tax amount in centi cents for a single unit.
      # Centi-cents = hundredths of a cent, used to preserve precision with integer arithmetic.
      #
      # @param product [Product] The product to calculate tax for
      # @return [Integer] The raw tax amount in centi-cents  or 0 if not applicable
      #
      # @example With $11.25 product and 10% tax rate:
      #   # price_cents = 1125, rate = 10
      #   # (1125 * 10) = 11250 centi-cents (represents 112.50 cents)
      def calculate_centicents_for_unit(product)
        return 0 unless applicable?(product)

        product.price.cents * rate_percent
      end
    end
  end
end
