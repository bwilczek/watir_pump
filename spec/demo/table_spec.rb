# frozen_string_literal: true

require_relative 'lib/pages/index_page'

RSpec.describe 'Table' do
  specify '#cols' do
    IndexPage.open do
      expect(products.cols).to contain_exactly('name', 'price', 'qty')
    end
  end

  specify '#data' do
    IndexPage.open do
      expect(products.data.count).to eq 4
      expect(products.data.first['name']).to eq 'Hammer'
    end
  end

  it 'delegates to #data' do
    IndexPage.open do
      expect(products.count).to eq 4
      expect(products.first['name']).to eq 'Hammer'
      expect(products[0]['name']).to eq 'Hammer'
    end
  end
end
