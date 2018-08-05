# frozen_string_literal: true

module WatirPump
  module Errors
    class ElementMismatch < StandardError
      def initialize(expected:, actual:, msg: nil)
        msg ||= "Element type mismatch. Expected: #{expected}, actual: #{actual}" # rubocop:disable Metrics/LineLength
        super(msg)
      end
    end
  end
end
