# frozen_string_literal: true

require_relative 'lib/pages/index_page'

RSpec.describe 'Table' do
  it '#cols' do
    IndexPage.open do
      expect(products.cols).to include('name', 'price', 'qty')
    end
  end

  it '#data' do
    IndexPage.open do
      expect(products.data.count).to eq 4
      expect(products.data.first['name']).to eq 'Hammer'
    end
  end
end
