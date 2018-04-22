# frozen_string_literal: true

require 'watir_pump'

class FormPage < WatirPump::Page
  uri '/form.html'

  text_field_accessor :name, name: 'name'
  textarea_accessor :description, name: 'description'
  radio_accessor :gender, name: 'gender'
  radio_accessor :predicate, name: 'predicate'
  checkbox_accessor :hobbies, name: 'hobbies[]'
  checkbox_accessor :continents, name: 'continents[]'
  select_accessor :car, name: 'car'
  select_accessor :ingredients, name: 'ingredients'
end
