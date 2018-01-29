module WatirPump
  class Component
    attr_reader :browser
    attr_reader :parent

    class << self
      %w[text_field button span div link].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            root.send(watir_method, *args, **keyword_args)
          end
        end
      end

      def component(name, klass, rel_method = nil, *rel_args)
        define_method(name) do
          root_node = rel_method.nil? ? root : root.send(rel_method, *rel_args)
          klass.new(browser, self, root_node, rel_method, *rel_args)
        end
      end

      def components(name, klass, rel_method = nil, *rel_args)
        define_method(name) do
          root.send(rel_method, *rel_args).map do |node|
            klass.new(browser, self, node, rel_method, *rel_args)
          end
        end
      end
    end

    def initialize(browser, parent = nil, root_node = nil, rel_method = nil, *rel_args)
      @browser = browser
      @parent = parent
      @rel_method = rel_method
      @rel_args = *rel_args
      @root_node = root_node
    end

    def root
      return @root_node if @root_node
      return browser.body if parent.nil?
      ret = @rel_method.nil? ? parent.root : parent.root.send(@rel_method, *@rel_args)
      return ret[0] if ret.class.name.include?('Collection')
    end
  end
end
