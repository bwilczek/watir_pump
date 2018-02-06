# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

RSpec.describe 'Page constructor' do
  it 'navigates across pages' do
    browser = WatirPump.config.browser
    page = IndexPage.new(browser)
    page.open
    page.top_menu.calculator.click
    expect(browser.url).to include('calculator.html')
    page = CalculatorPage.new(browser)
    expect(page.operand1).to be_visible
  end
end
