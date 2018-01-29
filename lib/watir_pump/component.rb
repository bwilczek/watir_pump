module WatirPump
  class Component
    attr_reader :browser
    attr_reader :parent

    class << self
      %w[text_field button span div].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            root.send(watir_method, *args, **keyword_args)
          end
        end
      end

      def component(name, klass, rel_method = nil, *rel_args)
        define_method(name) do
          @components[name] ||= klass.new(browser, self, rel_method, *rel_args)
        end
      end
    end

    def initialize(browser, parent = nil, rel_method = nil, *rel_args)
      @browser = browser
      @components = {}
      @parent = parent
      @rel_method = rel_method
      @rel_args = *rel_args
    end

    def root
      return browser.body if parent.nil?
      @rel_method.nil? ? parent.root : parent.root.send(@rel_method, *@rel_args)
    end
  end
end
