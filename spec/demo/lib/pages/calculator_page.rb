require 'watir_pump'

require_relative 'base_page'

class CalculatorPage < BasePage
  uri '/calculator.html{?query*}'
end
