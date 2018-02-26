# frozen_string_literal: true

module WatirPump
  class DecoratedElement
    def initialize(element)
      @element = element
    end

    def method_missing(name, *args, &blk)
      return @element.send(name, *args, &blk) if @element.respond_to?(name)
      super
    end

    def respond_to_missing?(name, include_private = false)
      @element.respond_to?(name) || super
    end
  end
end
