# frozen_string_literal: true

require_relative 'lib/pages/calculator_page'
require_relative 'lib/pages/index_page'

RSpec.describe 'Expectations' do
  it 'waits for the result' do
    CalculatorPage.open do
      add(2, 3)
      expect(result).to eq 5
    end
  end

  it 'expects collection to be visible and present' do
    IndexPage.open do
      expect(questions).to be_present
      expect(questions).to be_visible
    end
  end

  it 'resets the result' do
    CalculatorPage.open do
      sub(5, 2)
      expect(result).to eq 3
      reset
      expect(result_div.text).to eq '-'
    end
  end
end
