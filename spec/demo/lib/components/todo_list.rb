require 'watir_pump'

class ToDoList < WatirPump::Component
  text_field :new_item, role: 'new_item'
end
