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
      expect(gender).to eq 'Female'
      expect(predicate).to eq 'No'
    end
    # sleep 3
  end
end
