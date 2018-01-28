require 'addressable/template'
require_relative 'component'

module WatirPump
  class Page < Component
    attr_reader :browser

    class << self
      def uri(uri = nil)
        @uri = uri unless uri.nil?
        @uri
      end

      def open(params = {}, &blk)
        url_template = WatirPump.config.base_url + uri
        url = Addressable::Template.new(url_template).expand(params).to_s
        instance.browser.goto url
        use(&blk) if block_given?
      end

      def use
        yield instance, instance.browser
      end
      alias act use

      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    def initialize(browser)
      @browser = browser
    end

    def uri
      self.class.uri
    end
  end
end
