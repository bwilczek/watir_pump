# frozen_string_literal: true

require 'watir_pump'
require_relative 'todo_list_item'

class ToDoListCollection < WatirPump::ComponentCollection
  def [](title)
    find { |l| l.title == title }
  end
end
