# frozen_string_literal: true

module WatirPump
  module Constants
    METHODS_FORWARDED_TO_ROOT = %i[
      visible?
      present?
      wait_until_present
      wait_while_present
    ].freeze

    CLICKABLES = %i[
      button
      link
    ].freeze

    WRITABLES = %i[
      text_field
      text_area
    ].freeze

    READABLES = %i[
      div
      span
      p
    ].freeze
  end
end
