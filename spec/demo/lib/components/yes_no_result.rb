require 'watir_pump'

class YesNoResult < WatirPump::Component
  span :result, id: 'yay_nope'
end
