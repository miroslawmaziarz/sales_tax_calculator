# frozen_string_literal: true

require_relative 'tax_rule'

module SalesTaxCalculator
  module Tax
    # Basic tax rules
    class BasicSalesTaxRule < TaxRule
      RATE_PERCENT = 10

      def applicable?(item)
        !item.tax_exempt?
      end

      def rate_percent
        RATE_PERCENT
      end
    end
  end
end
