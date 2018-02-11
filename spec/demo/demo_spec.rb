# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

RSpec.describe 'Demo Sinatra App' do
  it 'page method call' do
    IndexPage.open do
      goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'URL params' do
    CalculatorPage.open(query: { operand1: 2, operand2: 4 }) do
      expect(browser.url).to include('operand1=2&operand2=4')
    end
  end

  it 'navigates across pages' do
    IndexPage.open do
      top_menu.calculator.click
      expect(browser.url).to include('calculator.html')
    end
    CalculatorPage.act do
      expect(operand1).to be_visible
    end
  end
end
