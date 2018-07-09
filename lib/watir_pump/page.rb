# frozen_string_literal: true

require 'forwardable'
require 'addressable/template'
require_relative 'component'

module WatirPump
  class Page < Component
    class << self
      extend Forwardable

      INSTANCE_DELEGATED_METHODS = %i[
        browser
        open open_yield open_dsl
        use use_yield use_dsl
        act act_yield use_dsl
      ].freeze
      delegate INSTANCE_DELEGATED_METHODS => :instance

      def uri(uri = nil)
        return @uri if @uri
        if uri.nil?
          ancestors[1..-1].each do |a|
            return @uri = a.uri if a.respond_to?(:uri) && a.uri
          end
        else
          @uri = uri
        end
        @uri
      end

      def loaded?
        Addressable::Template.new(instance.url_template).match browser.url
      end

      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    def open(params = {}, &blk)
      if WatirPump.config.call_page_blocks_with_yield
        open_yield(params, &blk)
      else
        open_dsl(params, &blk)
      end
    end

    def open_yield(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use_yield(&blk) if block_given?
      self
    end

    def open_dsl(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use_dsl(&blk) if block_given?
      self
    end

    def use(&blk)
      if WatirPump.config.call_page_blocks_with_yield
        use_yield(&blk)
      else
        use_dsl(&blk)
      end
    end
    alias act use

    def use_yield
      wait_for_loaded
      yield self, browser
      self
    end
    alias act_yield use_yield

    def use_dsl(&blk)
      wait_for_loaded
      instance_exec(&blk)
      self
    end
    alias act_dsl use_dsl

    def url_template
      WatirPump.config.base_url + self.class.uri
    end

    def wait_for_loaded
      Watir::Wait.until(message: "Timeout waiting for #{self} to load") do
        loaded?
      end
      self
    end

    def loaded?
      self.class.loaded?
    end

    def uri
      self.class.uri
    end
  end
end
