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
      link
      td
      h1
      h2
      h3
      h4
      h5
      h6
    ].freeze
  end
end
