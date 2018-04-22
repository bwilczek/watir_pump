# frozen_string_literal: true

require 'ostruct'
require_relative 'lib/pages/form_page'

RSpec.describe FormPage do
  it 'interacts with form elements' do
    FormPage.open do
      self.name = 'Kasia'
      self.description = 'Lubię koty oraz taniec wśród nietoperzy.'
      # require 'pry'; binding.pry
      self.gender = 'Female'
      self.predicate = 'No'
      self.hobbies = %w[Gardening Dancing]
      self.continents = %w[Europe Africa]
      self.car = 'Opel'
      self.ingredients = %w[Mozarella Eggplant]
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
    FormPage.open do
      data = OpenStruct.new.tap do |d|
        d.name = 'Kasia'
        d.description = 'Lubię koty oraz taniec wśród nietoperzy.'
        d.gender = 'Female'
        d.predicate = 'No'
        d.hobbies = %w[Gardening Dancing]
        d.continents = %w[Europe Africa]
        d.car = 'Opel'
        d.ingredients = %w[Mozarella Eggplant]
      end
      fill_form(data)
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
end
