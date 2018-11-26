# frozen_string_literal: true

module WatirPump
  module Constants
    METHODS_FORWARDED_TO_ROOT = %i[
      visible?
      present?
      stale?
      wait_until_present
      wait_while_present
      wait_until
      wait_while
      flash
    ].freeze

    CLICKABLES = %i[
      a
      button
      link
      div
      span
      li
      td
      th
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
      th
      text_field
      textarea
      h1
      h2
      h3
      h4
      h5
      h6
      li
    ].freeze
  end
end
