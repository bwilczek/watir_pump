# frozen_string_literal: true

require 'watir_pump'


class FormReaderWriterPage < WatirPump::Page
  uri '/form.html'

  splitter = ->(t) { t.split(', ') }

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
  select_writer :car, name: 'car'
  span_reader :car, id: 'res_car'
  select_writer :ingredients, name: 'ingredients[]'
  span_reader :ingredients, id: 'res_ingredients'
  decorate2 :ingredients, splitter

  button_clicker :submit, id: 'generate'

  def ingredients3
    root.span(id: 'res_ingredients').text.split(', ')
  end
end
