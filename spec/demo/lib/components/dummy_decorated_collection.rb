# frozen_string_literal: true

require 'watir_pump'

class DummyDecoratedCollection < WatirPump::ComponentCollection
  def count_times_three
    count * 3
  end
end
