require 'watir_pump'

class IndexPage < WatirPump::Page
  uri '/index.html'

  button :yes, id: 'btn_yay'
  span :result, id: 'yay_nope'

  # component :yes_no, YesNoWidget
end
