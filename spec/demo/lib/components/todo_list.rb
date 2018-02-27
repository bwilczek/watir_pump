# frozen_string_literal: true

require 'watir_pump'
require_relative 'todo_list_item'
require_relative 'dummy_decorated_collection'

class ToDoList < WatirPump::Component
  div_reader :title, role: 'title'
  text_field_writer :new_item, role: 'new_item'
  button_clicker :btn_add, role: 'add'
  components :items, ToDoListItem, :lis
  lis :items_raw
  decorate :items_raw, DummyDecoratedCollection

  def add(text)
    cnt_before = items.count
    self.new_item = text
    btn_add
    Watir::Wait.until { items.count == cnt_before + 1 }
  end

  def remove(text)
    cnt_before = items.count
    items.find { |i| i.name == text }.rm
    Watir::Wait.until { items.count == cnt_before - 1 }
  end
end
