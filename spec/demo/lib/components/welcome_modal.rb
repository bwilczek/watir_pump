require 'watir_pump'

class WelcomeModal < WatirPump::Component
  query :title, -> { node.span(class: 'ui-dialog-title').text }
  query :content, -> { node.div(class: 'ui-dialog-content').text }
  button :btn_close, class: 'ui-dialog-titlebar-close'
  query :close, -> { btn_close.click }
end
