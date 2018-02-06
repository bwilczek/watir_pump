# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

RSpec.describe 'Demo Sinatra App' do
  it 'page method call' do
    IndexPage.open do |page, browser|
      page.goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'URL params' do
    CalculatorPage.open(query: { operand1: 2, operand2: 4 }) do |_page, browser|
      expect(browser.url).to include('operand1=2&operand2=4')
    end
  end

  it 'navigates across pages' do
    IndexPage.open do |page, browser|
      page.top_menu.calculator.click
      expect(browser.url).to include('calculator.html')
    end
    CalculatorPage.act do |page, _browser|
      expect(page.operand1).to be_visible
    end
  end
end
