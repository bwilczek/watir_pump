# frozen_string_literal: true

require 'ostruct'
require_relative 'lib/pages/form_lambda_page'

RSpec.describe FormLambdaPage do
  let(:data) do
    OpenStruct.new.tap do |d|
      d.name = 'Kasia'
      d.description = 'Lubię koty oraz taniec wśród nietoperzy.'
      d.gender = 'Female'
      d.predicate = 'No'
      d.hobbies = %w[Gardening Dancing]
      d.continents = %w[Europe Africa]
      d.car = 'Opel'
      d.ingredients = %w[Mozarella Eggplant]
    end
  end

  it 'interacts with form elements' do
    FormLambdaPage.open do
      self.name = data.name
      self.description = data.description
      self.gender = data.gender
      self.predicate = data.predicate
      self.hobbies = data.hobbies
      self.continents = data.continents
      self.car = data.car
      self.ingredients = data.ingredients
      expect(name).to eq 'Kasia'
      expect(description).to include 'koty'
      expect(gender).to eq 'Female'
      expect(predicate).to eq 'No'
      expect(hobbies).to contain_exactly('Gardening', 'Dancing')
      expect(continents).to contain_exactly('Africa', 'Europe')
      expect(car).to eq 'Opel'
      expect(ingredients).to contain_exactly('Eggplant', 'Mozarella')
    end
  end

  it 'fills in the form' do
    FormLambdaPage.open do
      fill_form(data)
      expect(form_data).to eq data.to_h
    end
  end
end
