require_relative 'lib/pages/index_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'Table' do
  before(:all) do
    SinatraHelper.start
    WatirPump.config.base_url = 'http://localhost:4567'
  end

  after(:all) do
    SinatraHelper.stop
  end

  it '#cols' do
    IndexPage.open do |page, _browser|
      expect(page.products.cols).to include('name', 'price', 'qty')
    end
  end

  it '#data' do
    IndexPage.open do |page, _browser|
      expect(page.products.data.count).to eq 4
      expect(page.products.data.first['name']).to eq 'Hammer'
    end
  end
end
