#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/sales_tax_calculator'

# This script runs the supplied test data to demonstrate and verify
# that the sales tax calculator is working correctly.
module Examples
  # Execute the samples with Runner class
  # Eg. Examples::Runner.new.run
  class Runner
    def initialize
      @parser = SalesTaxCalculator::Parsers::ItemParser.new
    end

    def run
      puts '=' * 60
      puts 'SALES TAX CALCULATOR - TEST BASKETS'
      puts '=' * 60

      run_basket_one
      run_basket_two
      run_basket_three

      puts "\n#{'=' * 60}"
      puts 'All baskets processed successfully!'
      puts '=' * 60
    end

    private

    def run_basket_one
      puts "\n--- Basket 1 (Non-imported items) ---"
      puts 'Input:'

      input = <<~INPUT
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT

      puts input
      puts 'Output:'
      puts process_basket(input)
    end

    def run_basket_two
      puts "\n--- Basket 2 (Imported items) ---"
      puts 'Input:'

      input = <<~INPUT
        1 imported box of chocolates at 10.00
        1 imported bottle of perfume at 47.50
      INPUT

      puts input
      puts 'Output:'
      puts process_basket(input)
    end

    def run_basket_three
      puts "\n--- Basket 3 (Mixed items) ---", 'Input:'
      input = <<~INPUT
        1 imported bottle of perfume at 27.99
        1 bottle of perfume at 18.99
        1 packet of headache pills at 9.75
        3 imported box of chocolates at 11.25
      INPUT
      puts input, 'Output:', process_basket(input)
    end

    def process_basket(input)
      parsed_items = @parser.parse_all(input)
      basket = parsed_items.reduce(SalesTaxCalculator::Basket::ShoppingBasket.new) do |b, parsed|
        b.add(parsed.product, quantity: parsed.quantity)
      end
      SalesTaxCalculator::Basket::Receipt.new(basket).to_s
    end
  end
end

Examples::Runner.new.run
