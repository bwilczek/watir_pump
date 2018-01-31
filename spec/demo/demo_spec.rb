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

  it 'element directly on the page' do
    IndexPage.open do |page, _browser|
      expect(page.cat.attribute_value('alt')).to include('The cat is here')
    end
  end

  it 'element dynamically located using lambda' do
    IndexPage.open do |page, _browser|
      expect(page.btn_cnt).to eq 6
      expect(page.cat_alt).to include('The cat is here')
    end
  end

  it 'element dynamically located using lambda with param' do
    IndexPage.open do |page, _browser|
      page.yes0.click
      expect(page.questions[0].buttons.result.text).to eq 'Yay!'
      page.yes_n(2).click
      expect(page.questions[2].buttons.result.text).to eq 'Yay!'
    end
  end

  it 'flat component' do
    IndexPage.open do |page, browser|
      page.top_menu.calculator.click
      expect(browser.url).to include('calculator.html')
    end
  end

  it 'page method call' do
    IndexPage.open do |page, browser|
      page.goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'list of nested components' do
    IndexPage.open do |page, _browser|
      page.questions[1].buttons.yes.click
      expect(page.questions[1].buttons.result.text).to eq 'Yay!'
      page.questions[0].buttons.no.click
      expect(page.questions[0].buttons.result.text).to eq 'Nope.'
    end
  end

  it 'URL params' do
    CalculatorPage.open(query: { operand1: 2, operand2: 4 }) do |_page, browser|
      expect(browser.url).to include('operand1=2&operand2=4')
    end
  end
end
