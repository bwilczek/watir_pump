# frozen_string_literal: true

require 'watir_pump'

class ToDoListItem < WatirPump::Component
  link_clicker :rm, role: 'rm'
  span_reader :name, role: 'name'
end
