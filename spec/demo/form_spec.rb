# frozen_string_literal: true

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
      expect(gender).to eq 'Female'
      expect(predicate).to eq 'No'
      expect(hobbies).to contain_exactly('Gardening', 'Dancing')
      expect(continents).to contain_exactly('Africa', 'Europe')
    end
    # sleep 3
  end
end
