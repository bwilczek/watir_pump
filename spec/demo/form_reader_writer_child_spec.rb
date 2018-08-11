# frozen_string_literal: true

require 'ostruct'
require_relative 'lib/pages/form_reader_writer_child_page'

RSpec.describe FormReaderWriterChildPage do
  let(:data) do
    OpenStruct.new.tap do |d|
      d.name = 'Kasia'
      d.description = 'Lubię koty oraz taniec wśród nietoperzy.'
      d.gender = 'Female'
      d.predicate = 'No'
      d.confirmed = true
      d.hobbies = %w[Gardening Dancing]
      d.continents = %w[Europe Africa]
      d.car = 'Opel'
      d.ingredients = %w[Mozarella Eggplant]
    end
  end

  it 'fills submits the form automatically' do
    FormReaderWriterChildPage.open do
      fill_form!(data)
      expect(form_data).to eq data.to_h
    end
  end
end
