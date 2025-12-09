# frozen_string_literal: true

require_relative 'test_helper'

class ProductTest < Minitest::Test
  include TestHelpers

  def test_creates_product_with_required_attributes
    product = SalesTaxCalculator::Product.new(
      name: 'book',
      price: 12.49,
      imported: true,
      category: :book
    )

    assert_equal 'book', product.name
    assert_equal 1249, product.price.cents
    assert product.imported?
    assert_equal :book, product.category
  end

  def test_validates_required_fields
    assert_raises(ArgumentError) { create_product(name: '') }
    assert_raises(ArgumentError) { create_product(price: -10) }
    assert_raises(ArgumentError) { create_product(category: :invalid) }
  end

  def test_tax_exempt_categories
    assert create_product(category: :book).tax_exempt?
    assert create_product(category: :food).tax_exempt?
    assert create_product(category: :medical).tax_exempt?
    refute create_product(category: :general).tax_exempt?
  end

  def test_display_name_includes_imported_prefix
    assert_equal 'imported perfume', create_product(name: 'perfume', imported: true).display_name
    assert_equal 'book', create_product(name: 'book', imported: false).display_name
  end
end
