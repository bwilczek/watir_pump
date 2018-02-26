# frozen_string_literal: true

require 'watir_pump'

class DummyDecoratedElement < WatirPump::DecoratedElement
  def just_do_it
    'just_do_it'
  end
end
