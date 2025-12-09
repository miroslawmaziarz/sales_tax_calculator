# frozen_string_literal: true

require_relative 'tax_rule'

module SalesTaxCalculator
  module Tax
    # Import tax rules
    class ImportDutyRule < TaxRule
      RATE_PERCENT = 5

      def applicable?(item)
        item.imported?
      end

      def rate_percent
        RATE_PERCENT
      end
    end
  end
end
