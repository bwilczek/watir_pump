# frozen_string_literal: true

require 'forwardable'
require 'addressable/template'
require_relative 'component'

module WatirPump
  # Representation of a single page of the application under test.
  #
  # Implements +Singleton+ pattern.
  class Page < Component
    class << self
      extend Forwardable

      # List of class methods forwarded to the singleton instance
      INSTANCE_DELEGATED_METHODS = %i[
        browser
        open open_yield open_dsl
        use use_yield use_dsl
        act act_yield act_dsl
        loaded?
        matches_current_url?
        url_template
      ].freeze
      delegate INSTANCE_DELEGATED_METHODS => :instance

      # Class macro declaring Page's URI template. Example: +'/jobs/\{job_id}'+
      #
      # @see https://github.com/sporkmonger/addressable
      # @param [String] uri URI of current page.
      #   Compliant with +Addressable::Template+
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

      # Returns singleton instance of current Page
      #
      # @return [Page]
      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    # Returns complete (base plus URI) URL template for current Page
    #
    # @return [String]
    def url_template
      WatirPump.config.base_url + self.class.uri
    end

    # Opens the page in the browser and executes passed block in the scope
    # of the page instance. Depending on the value of
    # +WatirPump.config.call_page_blocks_with_yield+ method {open_yield}
    # or {open_dsl} is called internally
    #
    # @param [Hash] params Parameters for the URL template
    def open(params = {}, &blk)
      if WatirPump.config.call_page_blocks_with_yield
        open_yield(params, &blk)
      else
        open_dsl(params, &blk)
      end
    end

    # Opens the page in the browser and executes passed block in the scope
    # of the page instance. Current +page+ and +browser+ references are
    # passed to the yielded block.
    #
    # @example
    #   UserPage.open_yield(id: 123) do |page, browser|
    #     puts page.root.h1.text
    #     puts browser.title
    #   end
    #
    # @param [Hash] params Parameters for the URL template
    def open_yield(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use_yield(&blk) if block_given?
      self
    end

    # Opens the page in the browser and executes passed block in the scope
    # of the page instance (+instance_exec+).
    #
    # @example
    #   UserPage.open_dsl(id: 123) do
    #     puts root.h1.text
    #     puts browser.title
    #   end
    #
    # @param [Hash] params Parameters for the URL template
    def open_dsl(params = {}, &blk)
      url = Addressable::Template.new(url_template).expand(params).to_s
      browser.goto url
      use_dsl(&blk) if block_given?
      self
    end

    # Executes passed block in the scope of the page instance.
    # Depending on the value of
    # +WatirPump.config.call_page_blocks_with_yield+ method {use_yield}
    # or {use_dsl} is called internally
    def use(&blk)
      if WatirPump.config.call_page_blocks_with_yield
        use_yield(&blk)
      else
        use_dsl(&blk)
      end
    end
    alias act use

    # Executes passed block in the scope of the page instance.
    # Current +page+ and +browser+ references are
    # passed to the yielded block.
    #
    # @example
    #   UserPage.use_yield do |page, browser|
    #     puts page.root.h1.text
    #     puts browser.title
    #   end
    def use_yield
      wait_for_loaded
      yield self, browser
      self
    end
    alias act_yield use_yield

    # Executes passed block in the scope of the page instance.
    # (+instance_exec+)
    #
    # @example
    #   UserPage.use_dsl do
    #     puts root.h1.text
    #     puts browser.title
    #   end
    def use_dsl(&blk)
      wait_for_loaded
      instance_exec(&blk)
      self
    end
    alias act_dsl use_dsl

    # Waits until current Page is loaded
    #
    # @return [Page] self
    def wait_for_loaded
      Watir::Wait.until(message: "Timeout waiting for #{self} to load") do
        loaded?
      end
      self
    end

    # Predicate denoting if page is ready to be interacted with
    # Overload in child class to customize the readiness criteria
    #
    # @return [Boolean]
    def loaded?
      matches_current_url?
    end

    # Predicate denoting if current browser URL matches pages `uri` template
    #
    # @return [Boolean]
    def matches_current_url?
      Addressable::Template.new(url_template).match browser.url
    end
  end
end
