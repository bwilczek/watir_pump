module WatirPump
  class Component
    attr_reader :browser
    attr_reader :parent

    class << self
      %w[text_field button span div link image].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            root.send(watir_method, *args, **keyword_args)
          end
        end
      end

      def dynamic(name, p)
        define_method(name) do |*args|
          instance_exec(*args, &p)
        end
      end

      def component(name, klass, rel_method = nil, *rel_args)
        define_method(name) do
          root_node = rel_method.nil? ? root : root.send(rel_method, *rel_args)
          klass.new(browser, self, root_node)
        end
      end

      def components(name, klass, rel_method = nil, *rel_args)
        define_method(name) do
          root.send(rel_method, *rel_args).map do |node|
            klass.new(browser, self, node)
          end
        end
      end
    end

    def initialize(browser, parent = nil, root_node = nil)
      @browser = browser
      @parent = parent
      @root_node = root_node
    end

    def root
      return @root_node if @root_node
      return browser.body if parent.nil?
      ret = parent.root
      ret.class.name.include?('Collection') ? ret.first : ret
    end
  end
end
