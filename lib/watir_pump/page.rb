require 'addressable/template'

module WatirPump
  class Page
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

      def instance
        @instance ||= new(WatirPump.config.browser)
      end

      %w[text_field button title].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            browser.send(watir_method, *args, **keyword_args)
          end
        end
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
