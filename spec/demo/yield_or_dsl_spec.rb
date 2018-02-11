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

  it 'open_dsl' do
    IndexPage.open_dsl do
      goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  it 'use_dsl' do
    IndexPage.open
    IndexPage.use_dsl do
      goto_contact
      expect(browser.url).to include('contact.html')
    end
  end

  describe 'config' do
    describe 'yield' do
      before(:all) { WatirPump.config.call_page_blocks_with_yield = true }
      after(:all) { WatirPump.config.call_page_blocks_with_yield = false }

      it 'open' do
        IndexPage.open do |page, browser|
          page.goto_contact
          expect(browser.url).to include('contact.html')
        end
      end

      it 'use' do
        IndexPage.open
        IndexPage.use do |page, browser|
          page.goto_contact
          expect(browser.url).to include('contact.html')
        end
      end
    end

    describe 'dsl' do
      # no need to set up config: it's the default
      it 'open' do
        IndexPage.open do
          goto_contact
          expect(browser.url).to include('contact.html')
        end
      end

      it 'use' do
        IndexPage.open
        IndexPage.use do
          goto_contact
          expect(browser.url).to include('contact.html')
        end
      end
    end
  end
end
