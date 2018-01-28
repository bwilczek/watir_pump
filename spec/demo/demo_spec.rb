require_relative 'lib/pages/index_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'Demo Sinatra App' do
  before(:all) do
    SinatraHelper.start
    WatirPump.config.base_url = 'http://localhost:4567'
  end

  after(:all) do
    SinatraHelper.stop
  end

  it 'has the right title' do
    IndexPage.open do |page, browser|
      page.yes.click
      expect(page.result.text).to eq 'Yay!'
      expect(browser.title).to include('Wilhelmine')
    end
  end
end
