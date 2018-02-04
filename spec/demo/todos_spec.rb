require_relative 'lib/pages/todos_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'ToDos page' do
  before(:all) do
    SinatraHelper.start
    WatirPump.config.base_url = 'http://localhost:4567'
  end

  after(:all) do
    SinatraHelper.stop
  end

  describe 'Welcome modal' do
    it 'opens and closes' do
      ToDosPage.open do |page, _browser|
        # require 'pry' ; binding.pry
        expect(page.welcome_modal).not_to be_visible
        page.open_welcome_modal
        expect(page.welcome_modal).to be_visible
        expect(page.welcome_modal.title).to eq 'Welcome modal'
        expect(page.welcome_modal.title_element.text).to eq 'Welcome modal'
        expect(page.welcome_modal.content).to include 'Hello WatirPump!'
        page.welcome_modal.close
        expect(page.welcome_modal).not_to be_visible
      end
    end
  end
end
