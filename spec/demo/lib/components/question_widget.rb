# frozen_string_literal: true

require 'watir_pump'

require_relative 'yes_no_widget'

class QuestionWidget < WatirPump::Component
  span :question, data_role: 'question'
  component :buttons, YesNoWidget
end
