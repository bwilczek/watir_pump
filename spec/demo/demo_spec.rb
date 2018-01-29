require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'Demo Sinatra App' do
  before(:all) do
    SinatraHelper.start
    WatirPump.config.base_url = 'http://localhost:4567'
  end

  after(:all) do
    SinatraHelper.stop
  end

  it 'flat component' do
    IndexPage.open do |page, browser|
      page.top_menu.calculator.click
      expect(browser.url).to include('calculator.html')
    end
  end

  it 'nested components' do
    IndexPage.open do |page, _browser|
      page.questions[1].buttons.yes.click
      expect(page.questions[1].buttons.result.text).to eq 'Yay!'
      page.questions[0].buttons.no.click
      expect(page.questions[0].buttons.result.text).to eq 'Nope.'
    end
  end

  it 'passes URL params' do
    CalculatorPage.open(query: { operand1: 2, operand2: 4 }) do |_page, browser|
      expect(browser.url).to include('operand1=2&operand2=4')
    end
  end
end
