require 'forwardable'

module WatirPump
  class ComponentCollection
    extend Forwardable

    delegate Enumerable.instance_methods(false) => :@arr
    delegate %i[[] empty?] => :@arr

    def initialize(arr)
      @arr = arr
    end

    def present?
      return false if empty?
      first.node.present?
    end

    def visible?
      return false if empty?
      first.node.visible?
    end
  end
end
