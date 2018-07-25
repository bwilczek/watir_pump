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
      a
      button
      link
    ].freeze

    WRITABLES = %i[
      text_field
      textarea
    ].freeze

    READABLES = %i[
      a
      div
      span
      p
      link
      td
      text_field
      textarea
      h1
      h2
      h3
      h4
      h5
      h6
    ].freeze
  end
end
