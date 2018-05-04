# frozen_string_literal: true

require 'watir_pump'

class FormReaderWriterPage < WatirPump::Page
  uri '/form_rw.html'

  text_field_writer :name, name: 'name'
  span_reader :name, id: 'res_name'
  textarea_writer :description, name: 'description'
  span_reader :description, id: 'res_description'
  radio_writer :gender, name: 'gender'
  span_reader :gender, id: 'res_gender'
  radio_group :predicate, name: 'predicate'
  span_reader :predicate, id: 'res_predicate'
  # checkbox_accessor :hobbies, name: 'hobbies[]'
  # checkbox_group :continents, name: 'continents[]'
  # select_accessor :car, name: 'car'
  # dropdown_list :ingredients, name: 'ingredients[]'
  button_clicker :submit, id: 'generate'
end
