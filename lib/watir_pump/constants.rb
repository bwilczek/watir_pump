# frozen_string_literal: true

module WatirPump
  module Constants
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
