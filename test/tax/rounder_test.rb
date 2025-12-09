# frozen_string_literal: true

require_relative '../test_helper'

module SalesTaxCalculator
  module Tax
    class RounderTest < Minitest::Test
      include TestHelpers

      def setup
        @rounder = Rounder.new
      end

      def test_rounds_up_to_nearest_5_cents
        # 112.5 cents (11250 centicents) -> 115 cents (11500 centicents)
        assert_equal 11_500, @rounder.round_up_centicents(11_250)

        # 56.25 cents (5625 centicents) -> 60 cents (6000 centicents)
        assert_equal 6_000, @rounder.round_up_centicents(5_625)

        # 0.1 cents (10 centicents) -> 5 cents (500 centicents)
        assert_equal 500, @rounder.round_up_centicents(10)
      end

      def test_does_not_round_multiples_of_5_cents
        # 50 cents (5000 centicents) -> stays 50 cents
        assert_equal 5_000, @rounder.round_up_centicents(5_000)

        # 115 cents (11500 centicents) -> stays 115 cents
        assert_equal 11_500, @rounder.round_up_centicents(11_500)
      end

      def test_always_rounds_up_never_down
        # 5.1 cents should round UP to 10 cents, not down to 5
        assert_equal 1_000, @rounder.round_up_centicents(510)

        # 10.1 cents should round UP to 15 cents
        assert_equal 1_500, @rounder.round_up_centicents(1_010)
      end

      def test_handles_zero
        assert_equal 0, @rounder.round_up_centicents(0)
      end

      def test_rounds_up_smallest_amount
        # Even 0.01 cents rounds up to 5 cents
        assert_equal 500, @rounder.round_up_centicents(1)
      end
    end
  end
end
