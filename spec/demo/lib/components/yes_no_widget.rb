require 'watir_pump'

class YesNoWidget < WatirPump::Component
  button :yes, id: 'btn_yay'
  button :no, id: 'btn_nope'
  span :result, id: 'yay_nope'
end
