# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

def four4
  4
end

RSpec.describe 'Demo Sinatra App' do
  let(:two) { 2 }
  let(:four) { four4 }

  it 'page method call' do
    IndexPage.open do
      goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'URL params' do
    CalculatorPage.open(query: { operand1: two, operand2: four }) do
      expect(browser.url).to include('operand1=2&operand2=4')
    end
  end

  it 'decorated element' do
    CalculatorPage.open do
      expect(btn_add.just_do_it).to eq 'just_do_it'
    end
  end

  it 'navigates across pages' do
    IndexPage.open do
      top_menu.calculator.click
      expect(browser.url).to include('calculator.html')
    end
    CalculatorPage.act do
      expect(operand1).to be_present
    end
  end
end
