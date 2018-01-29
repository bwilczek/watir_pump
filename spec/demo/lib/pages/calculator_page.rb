require 'watir_pump'

class CalculatorPage < WatirPump::Page
  uri '/calculator.html{?query*}'
end
