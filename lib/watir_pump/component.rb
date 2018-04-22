# frozen_string_literal: true

require_relative 'component_collection'
require_relative 'decorated_element'
require_relative 'constants'
require 'forwardable'

module WatirPump
  class Component # rubocop:disable Metrics/ClassLength
    extend Forwardable

    include Constants

    delegate Constants::METHODS_FORWARDED_TO_ROOT => :root

    attr_reader :browser
    attr_reader :parent

    class << self
      # Proxy methods for HTML tags
      Watir::Container.instance_methods(false).each do |watir_method|
        define_method watir_method do |name, *args|
          return if public_methods.include? name
          define_method(name) do |*loc_args|
            if args&.first.is_a? Proc
              instance_exec(*loc_args, &args.first)
            else
              root.send(watir_method, *args)
            end
          end
        end
      end

      def self.define_reader(watir_method)
        define_method "#{watir_method}_reader" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          define_method(name) do
            el = send("#{name}_element")
            %w[input textarea].include?(el.tag_name) ? el.value : el.text
          end
        end
      end

      def self.define_writer(watir_method)
        define_method "#{watir_method}_writer" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          define_method("#{name}=") do |value|
            send("#{name}_element").set value
          end
        end
      end

      def self.define_accessor(watir_method)
        define_method "#{watir_method}_accessor" do |name, *args|
          send(watir_method, "#{name}_element", *args)
          # reader, TODO: DRY it up
          define_method(name) do
            el = send("#{name}_element")
            %w[input textarea].include?(el.tag_name) ? el.value : el.text
          end
          # writer, TODO: DRY it up
          define_method("#{name}=") do |value|
            send("#{name}_element").set value
          end
        end
      end

      # Methods for element content readers
      # span_reader, :title, id: asd
      # will create methods :title and :title_element
      # where :title is a shortcut for :title_element.text
      Constants::READABLES.each do |watir_method|
        define_reader(watir_method)
      end

      # Methods for element content writers
      Constants::WRITABLES.each do |watir_method|
        define_writer(watir_method)
      end

      # Methods for element content accessors
      (Constants::WRITABLES & Constants::READABLES).each do |watir_method|
        define_accessor(watir_method)
      end

      def radio_reader(name, *args)
        define_method name do
          selected = root.send(:radios, *args).find(&:set?)
          if selected
            return selected.parent.text if selected&.parent&.tag_name == 'label'
            return root.label(for: selected.id).text
          end
        end
      end

      def radio_writer(name, *args) # rubocop:disable Metrics/AbcSize
        define_method "#{name}=" do |value|
          # <label>value<input /></label>
          list = root.send(:radios, *args)
          if list.first.parent.tag_name == 'label'
            list.find { |el| el.parent.text == value }.set
          else
            # <label for='a'>value</label><input id='a' />
            list.find { |el| el.id == root.label(text: value).for }.set
          end
        end
      end

      def radio_accessor(name, *args)
        radio_reader(name, *args)
        radio_writer(name, *args)
      end

      def checkbox_writer(name, *args) # rubocop:disable Metrics/AbcSize
        define_method "#{name}=" do |values|
          values = Array(values)
          # <label>value<input /></label>
          list = root.send(:checkboxes, *args)
          values.each do |value|
            if list.first.parent.tag_name == 'label'
              list.find { |el| el.parent.text == value }.set
            else
              # <label for='a'>value</label><input id='a' />
              list.find { |el| el.id == root.label(text: value).for }.set
            end
          end
        end
      end

      def checkbox_reader(name, *args) # rubocop:disable Metrics/AbcSize
        define_method name do
          selected = root.send(:checkboxes, *args).select(&:set?)
          return [] unless selected
          if selected.first&.parent&.tag_name == 'label'
            return selected.map { |el| el.parent.text }
          end
          selected.map { |el| root.label(for: el.id).text }
        end
      end

      def checkbox_accessor(name, *args)
        checkbox_reader(name, *args)
        checkbox_writer(name, *args)
      end

      def select_reader(name, *args)
        define_method(name) do
          select = root.send(:select, *args)
          selected = select.selected_options
          return select.multiple? ? selected.map(&:text) : selected.first.text
        end
      end

      def select_writer(name, *args)
        define_method("#{name}=") do |values|
          select = root.send(:select, *args)
          return select.select(*values)
        end
      end

      def select_accessor(name, *args)
        select_reader(name, *args)
        select_writer(name, *args)
      end

      # Methods for element clickers
      Constants::CLICKABLES.each do |watir_method|
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

      def region(name, loc_method = nil, *loc_args, &blk)
        klass = Class.new(Component) { instance_exec(&blk) }
        component(name, klass, loc_method, *loc_args)
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

      def decorate(method, *klasses)
        klasses.each do |klass|
          original_name = "#{method}_before_#{klass}".to_sym
          alias_method original_name, method
          define_method method do |*args|
            klass.new(send(original_name, *args))
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

    def method_missing(name, *args)
      # delegate missing methods to current RSpec example if set
      example = WatirPump.config.current_example
      if example&.instance_exec { respond_to? name }
        return example.instance_exec { send(name, *args) }
      end
      super
    end

    def respond_to_missing?(name, include_private = false)
      example = WatirPump.config.current_example
      example&.instance_exec { respond_to? name } || super
    end
  end
end
