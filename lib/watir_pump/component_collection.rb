# frozen_string_literal: true

require 'forwardable'
require_relative 'constants'

module WatirPump
  class ComponentCollection
    extend Forwardable

    include Constants

    delegate Enumerable.instance_methods(false) => :@arr
    delegate %i[[] empty? each inspect last] => :@arr

    def initialize(arr)
      @arr = arr
    end

    Constants::METHODS_FORWARDED_TO_ROOT.each do |method_name|
      define_method method_name do
        return false if empty?
        find { |component| component.send(method_name) }
      end
    end
  end
end
