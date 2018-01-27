module WatirPump
  class Page
    attr_reader :browser

    class << self
      def uri(uri = nil)
        @uri = uri unless uri.nil?
        @uri
      end

      def open(&blk)
        instance.instance_eval do
          browser.goto WatirPump.config.base_url + uri
        end
        use(&blk) if block_given?
      end

      def use(&blk)
        instance.instance_eval(&blk)
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
