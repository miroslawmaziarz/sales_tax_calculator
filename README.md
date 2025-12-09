# Sales Tax Calculator

A Ruby application for calculating sales tax and generating receipts for shopping baskets.

## Problem Statement 

This problem requires some kind of input. You are free to implement any mechanism for feeding the input into your solution. You should provide sufficient evidence that your solution is complete by, as a minimum, indicating that it works correctly against the supplied test data.

**Basic sales tax** is applicable at a rate of **10%** on all goods, **except** books, food, and medical products that are exempt. **Import duty** is an additional sales tax applicable on all imported goods at a rate of 5%, with no exemptions.

When I purchase items I receive a receipt which lists the name of all the items and their price (including tax), finishing with the total cost of the items, and the total amounts of sales taxes paid. The rounding rules for sales tax are that for a tax rate of n%, a shelf price of p contains (np/100 rounded up to the nearest 0.05) amount of sales tax.


Write an application that prints out the receipt details for these shopping baskets:

### Input

#### Input 1:
```
2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
```

#### Input 2:
```
1 imported box of chocolates at 10.00
1 imported bottle of perfume at 47.50
```

#### Input 3:
```
1 imported bottle of perfume at 27.99
1 bottle of perfume at 18.99
1 packet of headache pills at 9.75
3 imported boxes of chocolates at 11.25
```

### Output

#### Output 1:
```
2 book: 24.98
1 music CD: 16.49
1 chocolate bar: 0.85
Sales Taxes: 1.50
Total: 42.32
```

#### Output 2:
```
1 imported box of chocolates: 10.50
1 imported bottle of perfume: 54.65
Sales Taxes: 7.65
Total: 65.15
```

#### Output 3:
```
1 imported bottle of perfume: 32.19
1 bottle of perfume: 20.89
1 packet of headache pills: 9.75
3 imported boxes of chocolates: 35.55
Sales Taxes: 7.90
Total: 98.38
```


## Requirements

- Ruby >= 3.2.0
- Bundler

## Assumptions
- Categories are identified by keywords, so they are uniq among the categories. Eg. A product like medical book is not allowed
  - In the real word the product type id should be passed to the calculator
- For faster calculations the prices are transfored to intigers with cents

## Installation

```bash
cd sales_tax_calculator
bundle install
```

## Running Tests

```bash
rake test
```

## Running Examples

Demonstrates the solution with the three test baskets:

```bash
ruby examples/run_examples.rb
```

## Architecture

Apply Domain Driven Design

### Directory Structure

```
lib/
├── sales_tax_calculator.rb    # Main entry point
├── money.rb                   # Shared value object that holds amount in integer for better performance
├── product.rb                 # Might be an aggregator in the future
│
├── basket/                    # Shopping Basket Aggregate
│   ├── shopping_basket.rb     # Aggregate Root
│   ├── item.rb                # Entity (line item within basket)
│   └── receipt.rb             # Read Model/View
│
├── tax/                       # Tax Calculation Domain
│   ├── tax_calculator.rb      # Domain Service
│   ├── rounder.rb             # Rounding logic
│   └── rules/                 # Tax Rules
│       ├── tax_rule.rb        # Tax rule interface
│       ├── basic_sales_tax_rule.rb
│       └── import_duty_rule.rb
│
└── parsers/                   # Input parsing
    └── item_parser.rb         # Input parsing
```

## Usage Examples

### Basic Usage

```ruby
require_relative 'lib/sales_tax_calculator'

# Create products
book = SalesTaxCalculator::Product.new(
  name: 'book',
  price: 12.49,
  category: :book
)

cd = SalesTaxCalculator::Product.new(
  name: 'music CD',
  price: 14.99,
  category: :general
)

# Build basket
basket = SalesTaxCalculator::Basket::ShoppingBasket.new
  .add(book)
  .add(cd)

# Generate receipt
receipt = SalesTaxCalculator::Basket::Receipt.new(basket)
puts receipt
```

### Using the Parser

```ruby
parser = SalesTaxCalculator::Parsers::ItemParser.new

input = <<~INPUT
  1 book at 12.49
  1 imported bottle of perfume at 27.99
INPUT

parsed_items = parser.parse_all(input)
basket = parsed_items.reduce(SalesTaxCalculator::Basket::ShoppingBasket.new) do |b, item| 
  b.add(item.product, quantity: item.quantity) 
end
receipt = SalesTaxCalculator::Basket::Receipt.new(basket)
puts receipt
```