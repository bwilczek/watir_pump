# frozen_string_literal: true

require 'active_support/configurable'
require 'watir'

require_relative 'watir_pump/page'

module WatirPump
  include ActiveSupport::Configurable
end
