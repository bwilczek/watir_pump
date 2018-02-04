require 'watir_pump'

class WelcomeModal < WatirPump::Component
  span_reader :title, class: 'ui-dialog-title'
  div_reader :content, -> { node.div(class: 'ui-dialog-content') }
  button :btn_close, class: 'ui-dialog-titlebar-close'
  query :close, -> { btn_close.click }
end
