# frozen_string_literal: true

require_relative 'component_collection'
require 'forwardable'

module WatirPump
  class Component
    extend Forwardable

    delegate %i[visible? present?] => :root

    attr_reader :browser
    attr_reader :parent

    class << self
      # Proxy methods for HTML tags
      Watir::Container.instance_methods(false).each do |watir_method|
        define_method watir_method do |name, *args|
          define_method(name) do |*loc_args|
            if args&.first.is_a? Proc
              instance_exec(*loc_args, &args.first)
            else
              root.send(watir_method, *args)
            end
          end
        end
      end

      # Methods for element content readers
      # span_reader, :title, id: asd
      # will create methods :title and :title_element
      # where :title is a shortcut for :title_element.text
      %i[span div].each do |watir_method|
        define_method "#{watir_method}_reader" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          define_method(name) do
            send("#{name}_element").text
          end
        end
      end

      # Methods for element content writers
      %i[text_field].each do |watir_method|
        define_method "#{watir_method}_writer" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          define_method("#{name}=") do |value|
            send("#{name}_element").set value
          end
        end
      end

      # Methods for element clickers
      %i[button link].each do |watir_method|
        define_method "#{watir_method}_clicker" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          define_method(name) do
            send("#{name}_element").click
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
          ComponentCollection.new(nodes.map { |n| klass.new(browser, self, n) })
        end
      end

      def decorate(method, klass)
        alias_method "#{method}_original".to_sym, method
        define_method method do |*args|
          klass.new(send("#{method}_original", *args))
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
