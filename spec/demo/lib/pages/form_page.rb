# frozen_string_literal: true

require 'watir_pump'

class FormPage < WatirPump::Page
  uri '/form.html'

  text_field_writer :name, name: 'name'
  textarea_writer :description, name: 'description'
  radio_writer :gender, name: 'gender'
  radio_reader :gender, name: 'gender'
  radio_writer :predicate, name: 'predicate'
  radio_reader :predicate, name: 'predicate'
  checkbox_writer :hobbies, name: 'hobbies[]'
  checkbox_reader :hobbies, name: 'hobbies[]'
  checkbox_writer :continents, name: 'continents[]'
  checkbox_reader :continents, name: 'continents[]'
end
