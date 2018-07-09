# frozen_string_literal: true

require 'set'
require 'forwardable'

require_relative 'component_collection'
require_relative 'decorated_element'
require_relative 'constants'
require_relative 'components/radio_group'
require_relative 'components/checkbox_group'
require_relative 'components/dropdown_list'

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
          return if public_instance_methods.include? name
          define_method(name) do |*loc_args|
            find_element(watir_method, args, loc_args)
          end
        end
      end

      def form_field_readers
        @form_field_readers ||= Set.new
      end

      def form_field_writers
        @form_field_writers ||= Set.new
      end

      include Components::RadioGroup
      include Components::CheckboxGroup
      include Components::DropdownList

      def custom_reader(name, code = nil)
        form_field_readers << name
        query(name, code) if code
      end

      def custom_writer(name, code = nil)
        form_field_writers << name
        query("#{name}=", code) if code
      end

      def self.define_reader(watir_method)
        define_method "#{watir_method}_reader" do |name, *args|
          send(watir_method, "#{name}_reader_element", *args)
          form_field_readers << name
          define_method(name) do
            el = send("#{name}_reader_element")
            %w[input textarea].include?(el.tag_name) ? el.value : el.text
          end
        end
      end

      def self.define_writer(watir_method)
        define_method "#{watir_method}_writer" do |name, *args|
          send(watir_method, "#{name}_writer_element", *args)
          form_field_writers << name
          define_method("#{name}=") do |value|
            send("#{name}_writer_element").set value
          end
        end
      end

      def self.define_accessor(watir_method) # rubocop:disable Metrics/AbcSize
        define_method "#{watir_method}_accessor" do |name, *args|
          send(watir_method, "#{name}_accessor_element", *args)
          # reader, TODO: DRY it up
          form_field_readers << name
          define_method(name) do
            el = send("#{name}_accessor_element")
            %w[input textarea].include?(el.tag_name) ? el.value : el.text
          end
          # writer, TODO: DRY it up
          form_field_writers << name
          define_method("#{name}=") do |value|
            send("#{name}_accessor_element").set value
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

      # Methods for element clickers
      Constants::CLICKABLES.each do |watir_method|
        define_method "#{watir_method}_clicker" do |name, *args|
          send(watir_method, "#{name}_clicker_element", *args)
          define_method(name) do
            send("#{name}_clicker_element").click
          end
        end
      end

      def query(name, p)
        define_method(name) do |*args|
          instance_exec(*args, &p)
        end
      end
      alias element query
      alias elements query

      def region(name, loc_method = nil, *loc_args, &blk)
        klass = Class.new(Component) { instance_exec(&blk) }
        component(name, klass, loc_method, *loc_args)
      end

      def component(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          node = find_element_raw(watir_method: loc_method,
                                  watir_method_args: loc_args,
                                  code: loc_method,
                                  code_args: args)
          klass.new(browser, self, node)
        end
      end

      def components(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          nodes = find_element_raw(watir_method: loc_method,
                                   watir_method_args: loc_args,
                                   code: loc_method,
                                   code_args: args)
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

      def decorate2(method, code)
        original_name = "#{method}_before_decorate2".to_sym
        alias_method original_name, method
        define_method method do |*args|
          v = send(original_name, *args)
          instance_exec(v, &code)
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

    def form_field_writers
      return @form_field_writers if @form_field_writers
      @form_field_writers = Set.new
      self.class.ancestors.each do |a|
        if a.respond_to? :form_field_writers
          @form_field_writers += a.form_field_writers
        end
      end
      @form_field_writers
    end

    def form_field_readers
      return @form_field_readers if @form_field_readers
      @form_field_readers = Set.new
      self.class.ancestors.each do |a|
        if a.respond_to? :form_field_readers
          @form_field_readers += a.form_field_readers
        end
      end
      @form_field_readers
    end

    def fill_form(data)
      missing = data.to_h.keys - form_field_writers.to_a
      unless missing.empty?
        raise "#{self.class.name} does not contain writer(s) for #{missing}"
      end
      data.to_h.each_pair do |k, v|
        send("#{k}=", v)
      end
    end

    def fill_form!(data)
      fill_form(data)
      raise ':fill_form! requries :submit method' unless respond_to? :submit
      submit
    end

    def form_data
      {}.tap do |h|
        form_field_readers.map do |field|
          h[field] = send(field)
        end
      end
    end

    def find_element(watir_method, args, loc_args = nil)
      find_element_raw(watir_method: watir_method,
                       watir_method_args: args,
                       code: args.first,
                       code_args: loc_args)
    end

    def find_element_raw(watir_method: nil, watir_method_args: nil, code: nil, code_args: nil) # rubocop:disable Metrics/LineLength
      if code.is_a? Proc
        instance_exec(*code_args, &code)
      elsif watir_method
        root.send(watir_method, *watir_method_args)
      end
    end

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
