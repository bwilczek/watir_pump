# frozen_string_literal: true

require 'set'
require 'forwardable'

require_relative 'errors/element_mismatch'
require_relative 'component_collection'
require_relative 'decorated_element'
require_relative 'constants'
require_relative 'watir_method_mapping'
require_relative 'components/radio_group'
require_relative 'components/checkbox_group'
require_relative 'components/dropdown_list'
require_relative 'components/flag'

module WatirPump
  # Representation of a reusable page component.
  #
  # Next to class methods documented below it contains also dynamically
  # generated methods for declaring +Watir::Elements+ belonging to the
  # component.
  #
  # See {WatirPump::WATIR_METHOD_MAPPING} for a complete list of elemet methods.
  #
  # There are also dynamically generated class methods that create +reader+,
  # +writer+ and +clicker+ instance methods.
  # Please refer to {file:README.md} for more details.
  #
  # @example
  #   class MyComponent < WatirPump::Component
  #     # declaration of a div element
  #     # instance method `description` returns Watir::Div
  #     div :description, id: 'desc'
  #
  #     # declaration of a div element reader
  #     # instance method `description` returns String
  #     div_reader :description, id: 'desc'
  #
  #     # declaration of a button element clicker
  #     # instance method `login` clicks on the button
  #     button_clicker :login, id: 'submit'
  #
  #     # declaration of a text_field writer
  #     # instance method `surname=(value)` sets value of the text_field
  #     text_field_writer :surname, id: 'surname'
  #   end
  class Component # rubocop:disable Metrics/ClassLength
    extend Forwardable

    include Constants

    delegate Constants::METHODS_FORWARDED_TO_ROOT => :root

    # Reference to browser instance
    # @return [Watir::Browser]
    attr_reader :browser

    # Parent {Component}. +nil+ for Pages
    # @return [Component]
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

      # Returns a set of declared element readers. Used by {form_data}
      #
      # @return [Set<Symbol>]
      def form_field_readers
        @form_field_readers ||= Set.new
      end

      # Returns a set of declared element writers. Used by {fill_form}
      #
      # @return [Set<Symbol>]
      def form_field_writers
        @form_field_writers ||= Set.new
      end

      include Components::RadioGroup
      include Components::CheckboxGroup
      include Components::DropdownList
      include Components::Flag

      # Declares a custom element reader.
      # @example
      #   custom_reader :price, -> { root.span(id: 'price').text.to_f }
      #   custom_reader :price2
      #
      #   def price2
      #     root.span(id: 'price').text.to_f
      #   end
      #
      # @param [Symbol] name Name of the reader method
      # @param [Proc] Method body (optional). If not provided a regular instance
      #   with given name has to be declared
      def custom_reader(name, code = nil)
        form_field_readers << name
        query(name, code) if code
      end

      # Declares a custom element writer.
      # @example
      #   custom_writer :price, ->(v) { root.text_field(id: 'price').set(v) }
      #   custom_writer :price2
      #
      #   def price2=(v)
      #     root.text_field(id: 'price').set(v)
      #   end
      #
      # @param [Symbol] name Name of the writer method (without trailing '=')
      # @param [Proc] Method body (optional). If not provided a regular instance
      #   with given name (with trailing '=') has to be declared
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
      private_class_method :define_reader

      def self.define_writer(watir_method)
        define_method "#{watir_method}_writer" do |name, *args|
          send(watir_method, "#{name}_writer_element", *args)
          form_field_writers << name
          define_method("#{name}=") do |value|
            send("#{name}_writer_element").set value
          end
        end
      end
      private_class_method :define_writer

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
      private_class_method :define_accessor

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

      # A shorthand to generate one-liner instance methods
      #
      # @example
      #   query :sum, ->(a, b) { a + b }
      #   # is equivalent to:
      #   def sum(a, b)
      #     a + b
      #   end
      #
      # @param [Symbol] name Name of the method
      # @param [Proc] p Body of the method
      def query(name, p)
        define_method(name) do |*args|
          instance_exec(*args, &p)
        end
      end

      # Declares an element located with lambda.
      # @example
      #   element :name, -> { root.span(id: 'name') }
      #
      # @return [Watir::Element]
      def element(name, p)
        define_method(name) do |*args|
          ret = instance_exec(*args, &p)
          unless ret.is_a?(Watir::Element)
            raise Errors::ElementMismatch.new(
              expected: Watir::Element,
              actual: ret.class
            )
          end
          ret
        end
      end

      # Declares an element collection located with lambda.
      # @example
      #   # mind the plural in watir method name: `lis` - not `li`!
      #   elements :items, -> { root.lis(class: 'item') }
      #
      # @return [Watir::ElementCollection]
      def elements(name, p)
        define_method(name) do |*args|
          ret = instance_exec(*args, &p)
          unless ret.is_a?(Watir::ElementCollection)
            raise Errors::ElementMismatch.new(
              expected: Watir::ElementCollection,
              actual: ret.class
            )
          end
          ret
        end
      end

      # Declares anonymous component (namespace).
      # @example
      #   class HomePage < WatirPump::Page
      #     region :login_box, :div, id: 'login_box' do
      #       text_field :username, id: 'user'
      #       text_field :password, id: 'pass'
      #       button :login, id: 'login'
      #     end
      #
      #     def do_login(user, pass)
      #       login_box.username.set user
      #       login_box.password.set pass
      #       login_box.login.click
      #     end
      #   end
      def region(name, loc_method = nil, *loc_args, &blk)
        klass = Class.new(Component) { instance_exec(&blk) }
        component(name, klass, loc_method, *loc_args)
      end

      # Declares a component of a given class under a given method name.
      # @example
      #   component :login_form1, LoginForm, :div, id: 'login_form1'
      #   component :login_form2, LoginForm, -> { root.div(id: 'login_form2') }
      #
      # @param [Symbol] name Name of the method to access the component instance
      # @param [Class] klass Class of the declared component
      def component(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          node = find_element_raw(watir_method: loc_method,
                                  watir_method_args: loc_args,
                                  code: loc_method,
                                  code_args: args)
          unless node.is_a?(Watir::Element) || node.nil?
            raise Errors::ElementMismatch.new(
              expected: Watir::Element,
              actual: node.class
            )
          end
          klass.new(browser, self, node)
        end
      end

      # Declares a component collection
      #   of a given class under a given method name.
      # @example
      #   components :products1, ProductList, :divs, class: 'product'
      #   components :products2, ProductList, -> { root.divs(class: 'product') }
      #
      # @param [Symbol] name Name of the method to access the component list
      # @param [Class] klass Class of the component in the list
      def components(name, klass, loc_method = nil, *loc_args)
        define_method(name) do |*args|
          nodes = find_element_raw(watir_method: loc_method,
                                   watir_method_args: loc_args,
                                   code: loc_method,
                                   code_args: args)
          unless nodes.is_a?(Watir::ElementCollection)
            raise Errors::ElementMismatch.new(
              expected: Watir::ElementCollection,
              actual: nodes.class
            )
          end
          ComponentCollection.new(nodes.map { |n| klass.new(browser, self, n) })
        end
      end

      # Decorate the result of given method with a list of wrapper classes.
      #
      # @example
      #   decorate :products, ProductCollection, AccessByNameCollection
      #
      # @param [Symbol] method Name of the method to be decorated
      # @param [*Class] klasses List of wrapper classes
      def decorate(method, *klasses)
        klasses.each do |klass|
          original_name = "#{method}_before_#{klass}".to_sym
          alias_method original_name, method
          define_method method do |*args|
            klass.new(send(original_name, *args))
          end
        end
      end
    end # << self

    # Invoked implicity by WatirPump framework.
    #
    # @param [Watir::Browser] browser Reference to browser instance
    # @param [Component] parent Parent Component
    # @param [Watir::Element] root_node Component mounting point in the DOM tree
    def initialize(browser, parent = nil, root_node = nil)
      @browser = browser
      @parent = parent
      @root_node = root_node
    end

    # Component mounting point in the DOM tree.
    # All component elements are located relatively to it.
    # For {Page} instances it points to +browser+
    #
    # @return [Watir::Element]
    def root
      return @root_node if @root_node
      return browser if parent.nil?
      parent.root
    end
    alias node root

    # Invokes element writer methods of given names with given values
    # @example
    #   class MyPage < WatirPump::Page
    #     text_field_writer :first_name, id: 'first_name'
    #     text_field_writer :last_name, id: 'last_name'
    #     flag_writer :confirmed, id: 'confirmed'
    #   end
    #   MyPage.use do
    #     fill_form(first_name: 'John', last_name: 'Smith', confirmed: true)
    #     # is a shorthand for:
    #     self.first_name = 'John'
    #     self.last_name = 'Smith'
    #     self.confirmed = true
    #   end
    #
    # @param Hash data Names of writer methods (symbols), and values for them.
    def fill_form(data)
      missing = data.to_h.keys - form_field_writers.to_a
      unless missing.empty?
        raise "#{self.class.name} does not contain writer(s) for #{missing}"
      end
      data.to_h.each_pair do |k, v|
        send("#{k}=", v)
      end
    end

    # Same as {fill_form} but additionally invokes `submit` method if it exists.
    # Otherwise raises an Exception.
    #
    # @param Hash data Names of writer methods (symbols), and values for them.
    def fill_form!(data)
      fill_form(data)
      raise ':fill_form! requries :submit method' unless respond_to? :submit
      submit
    end

    # Invokes all reader methods at once and returns their values.
    # @example
    #   class MyPage < WatirPump::Page
    #     span_reader :first_name, id: 'first_name'
    #     span_reader :last_name, id: 'last_name'
    #     flag_reader :confirmed, id: 'confirmed'
    #   end
    #   MyPage.use do
    #     data = form_data
    #     data == {first_name: 'John', last_name: 'Smith', confirmed: true}
    #   end
    #
    # @return [Hash] Names of declared reader methods (symbols)
    #   and values they returned.
    def form_data
      {}.tap do |h|
        form_field_readers.map do |field|
          h[field] = send(field)
        end
      end
    end

    private

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

    def find_element(watir_method, args, loc_args = nil)
      find_element_raw(watir_method: watir_method,
                       watir_method_args: args,
                       code: args.first,
                       code_args: loc_args)
    end

    def find_element_raw(watir_method: nil, watir_method_args: nil, code: nil, code_args: nil) # rubocop:disable Metrics/LineLength
      if code.is_a? Proc
        evaluated = instance_exec(*code_args, &code)
        check_watir_method_mapping(watir_method, evaluated)
      elsif watir_method
        root.send(watir_method, *watir_method_args)
      end
    end

    # Raise error if watir_method (e.g. :image)
    #  does not correspond to returned element (e.g. Watir::Table)
    def check_watir_method_mapping(watir_method, evaluated)
      return evaluated unless watir_method.is_a?(Symbol)
      return evaluated if evaluated.class == WATIR_METHOD_MAPPING[watir_method]
      raise Errors::ElementMismatch.new(
        expected: WATIR_METHOD_MAPPING[watir_method],
        actual: evaluated.class
      )
    end

    def method_missing(name, *args, &blk)
      # delegate missing methods to current RSpec example if set
      example = WatirPump.config.current_example
      if example&.instance_exec { respond_to? name }
        return example.instance_exec { send(name, *args, &blk) }
      end
      super
    end

    def respond_to_missing?(name, include_private = false)
      example = WatirPump.config.current_example
      example&.instance_exec { respond_to? name } || super
    end
  end
end
