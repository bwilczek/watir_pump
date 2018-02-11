# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

RSpec.describe 'Do not change lexical self to Component' do
  it 'open_yield' do
    IndexPage.open_yield do |page, browser|
      page.goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'use_yield' do
    IndexPage.open
    IndexPage.use_yield do |page, browser|
      page.goto_contact
      expect(browser.url).to include('contact.html')
    end
  end
end
