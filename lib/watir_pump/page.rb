require 'addressable/template'
require_relative 'component'

module WatirPump
  class Page < Component
    class << self
      def uri(uri = nil)
        @uri = uri unless uri.nil?
        @uri
      end

      def url_template
        WatirPump.config.base_url + uri
      end

      def open(params = {}, &blk)
        url = Addressable::Template.new(url_template).expand(params).to_s
        instance.browser.goto url
        use(&blk) if block_given?
      end

      def browser
        instance.browser
      end

      def loaded?
        Addressable::Template.new(url_template).match browser.url
      end

      def use
        # TODO: add more verbose message on timeout
        Watir::Wait.until { instance.loaded? }
        yield instance, instance.browser
      end
      alias act use

      def instance
        @instance ||= new(WatirPump.config.browser)
      end
    end # << self

    def loaded?
      self.class.loaded?
    end

    def uri
      self.class.uri
    end
  end
end
