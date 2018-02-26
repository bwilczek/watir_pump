# frozen_string_literal: true

require 'forwardable'

module WatirPump
  class ComponentCollection
    extend Forwardable

    delegate Enumerable.instance_methods(false) => :@arr
    delegate %i[[] empty? each] => :@arr

    def initialize(arr)
      @arr = arr
    end

    %i[present? visible?].each do |method_name|
      define_method method_name do
        return false if empty?
        find { |component| component.root.send(method_name) }
      end
    end
  end
end
