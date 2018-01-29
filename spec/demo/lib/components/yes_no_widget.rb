require 'watir_pump'

require_relative 'yes_no_result'

class YesNoWidget < WatirPump::Component
  button :yes, id: 'btn_yay'
  button :no, id: 'btn_nope'
  component :result_wrapper, YesNoResult, :span, id: 'yay_nope'
end
