module WatirPump
  class Component
    attr_reader :browser
    attr_reader :root

    class << self
      %w[text_field button title span div].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            root.call.send(watir_method, *args, **keyword_args)
          end
        end
      end

      def component(name, klass, root = nil)
        define_method(name) do
          @components[name] ||= klass.new(browser, root)
        end
      end
    end

    def initialize(browser, root = nil)
      default_root = -> { browser.body }
      @browser = browser
      @components = {}
      @root = root.nil? ? default_root : root
    end
  end
end
