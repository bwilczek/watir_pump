# frozen_string_literal: true

require 'watir_pump'

class YesNoWidget < WatirPump::Component
  button :yes, data_role: 'btn_yes'
  button :no, data_role: 'btn_no'
  span :result, data_role: 'yes_or_no'
end
