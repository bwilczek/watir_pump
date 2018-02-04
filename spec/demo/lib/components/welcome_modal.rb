require 'watir_pump'

class WelcomeModal < WatirPump::Component
  span :title, class: 'ui-dialog-title'
  div :content, class: 'ui-dialog-content'
  button :btn_close, class: 'ui-dialog-titlebar-close'
  query :close, -> { btn_close.click }
end
