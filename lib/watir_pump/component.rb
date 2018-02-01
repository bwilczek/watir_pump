module WatirPump
  class Component
    attr_reader :browser
    attr_reader :parent

    class << self
      %w[text_field button span div link image].each do |watir_method|
        define_method watir_method do |name, *args|
          define_method(name) do |*loc_args|
            if args.first.is_a? Proc
              instance_exec(*loc_args, &args.first)
            else
              root.send(watir_method, *args)
            end
          end
        end
      end

      def query(name, p)
        define_method(name) do |*args|
          instance_exec(*args, &p)
        end
      end

      def component(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          node = if loc_method.is_a? Proc
                   instance_exec(*args, &loc_method)
                 else
                   loc_method.nil? ? root : root.send(loc_method, *loc_args)
                 end
          klass.new(browser, self, node)
        end
      end

      def components(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          nodes = if loc_method.is_a? Proc
                    instance_exec(*args, &loc_method)
                  else
                    root.send(loc_method, *loc_args)
                  end
          nodes.map do |node|
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
    alias node root
  end
end
