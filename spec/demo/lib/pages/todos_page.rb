# frozen_string_literal: true

require 'watir_pump'

require_relative '../components/welcome_modal'
require_relative '../components/todo_list'

class ToDosPage < WatirPump::Page
  uri '/todos.html{?query*}'
  query :loaded?, -> { todo_lists.present? }

  component :welcome_modal, WelcomeModal, -> { browser.div(id: 'welcome_modal').parent }
  button :btn_open_welcome_modal, id: 'welcome_modal_opener'
  query :open_welcome_modal, -> { btn_open_welcome_modal.click }

  components :todo_lists, ToDoList, :divs, role: 'todo_list'

  def [](title)
    todo_lists.find { |l| l.title == title }
  end
end
