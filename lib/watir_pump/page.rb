# frozen_string_literal: true

require 'addressable/template'
require_relative 'component'

module WatirPump
  class Page < Component
    class << self
      def uri(uri = nil)
        @uri = uri unless uri.nil?
        @uri
      end

      def open(params = {}, &blk)
        instance.open(params, &blk)
      end

      def browser
        instance.browser
      end

      def use(&blk)
        instance.use(&blk)
      end
      alias act use

      def loaded?
        Addressable::Template.new(instance.url_template).match browser.url
      end

      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    def open(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use(&blk) if block_given?
      self
    end

    def use
      wait_for_loaded
      yield self, browser
      self
    end
    alias act use

    def url_template
      WatirPump.config.base_url + self.class.uri
    end

    def wait_for_loaded
      Watir::Wait.until(message: "Timeout waiting for #{self} to load") do
        loaded?
      end
    end

    def loaded?
      self.class.loaded?
    end

    def uri
      self.class.uri
    end
  end
end
