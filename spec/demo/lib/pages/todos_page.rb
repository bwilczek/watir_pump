require 'watir_pump'

require_relative '../components/welcome_modal'

class ToDosPage < WatirPump::Page
  uri '/todos.html'
  component :welcome_modal, WelcomeModal, -> { browser.div(id: 'welcome_modal').parent }
  button :btn_open_welcome_modal, id: 'welcome_modal_opener'
  query :open_welcome_modal, -> { btn_open_welcome_modal.click }
end
