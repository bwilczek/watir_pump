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

      def open_yield(params = {}, &blk)
        instance.open_yield(params, &blk)
      end

      def browser
        instance.browser
      end

      def use(&blk)
        instance.use(&blk)
      end
      alias act use

      def use_yield(&blk)
        instance.use_yield(&blk)
      end
      alias act_yield use_yield

      def loaded?
        Addressable::Template.new(instance.url_template).match browser.url
      end

      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    def open_yield(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use_yield(&blk) if block_given?
      self
    end

    def open(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use(&blk) if block_given?
      self
    end

    def use_yield
      wait_for_loaded
      yield self, browser
      self
    end
    alias act_yield use_yield

    def use(&blk)
      wait_for_loaded
      instance_exec(&blk)
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
