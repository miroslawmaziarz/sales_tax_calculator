# frozen_string_literal: true

require_relative 'test_helper'

class MoneyTest < Minitest::Test
  include TestHelpers

  def test_creates_money_from_decimal_amount
    money = SalesTaxCalculator::Money.from_amount(12.49)

    assert_equal 1249, money.cents
  end

  def test_raises_error_for_negative_amount
    assert_raises(SalesTaxCalculator::Money::NegativeAmountError) do
      SalesTaxCalculator::Money.from_amount(-10.00)
    end
  end

  def test_adds_two_money_objects
    money1 = SalesTaxCalculator::Money.new(1249)
    money2 = SalesTaxCalculator::Money.new(1499)

    result = money1 + money2

    assert_equal 2748, result.cents
  end

  def test_multiplies_by_quantity
    money = SalesTaxCalculator::Money.new(100)

    result = money * 3

    assert_equal 300, result.cents
  end

  def test_formats_as_currency_string
    assert_equal '12.49', SalesTaxCalculator::Money.new(1249).to_s
    assert_equal '0.05', SalesTaxCalculator::Money.new(5).to_s
    assert_equal '0.00', SalesTaxCalculator::Money.new(0).to_s
  end
end
