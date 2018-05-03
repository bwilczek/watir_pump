# frozen_string_literal: true

require 'watir_pump'

class FormLambdaPage < WatirPump::Page
  uri '/form.html'

  text_field_accessor :name, -> { root.text_field(name: 'name') }
  textarea_accessor :description, -> { root.textarea(name: 'description') }
  radio_accessor :gender, -> { root.radios(name: 'gender') }
  radio_group :predicate, -> { root.radios(name: 'predicate') }
  checkbox_accessor :hobbies, -> { root.checkboxes(name: 'hobbies[]') }
  checkbox_group :continents, -> { root.checkboxes(name: 'continents[]') }
  select_accessor :car, -> { root.select(name: 'car') }
  dropdown_list :ingredients, -> { root.select(name: 'ingredients[]') }
end
