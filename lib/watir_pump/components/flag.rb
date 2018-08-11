# frozen_string_literal: true

module WatirPump
  module Components
    module Flag
      def flag_writer(name, *args)
        form_field_writers << name
        define_method "#{name}=" do |value|
          element = find_element(:checkbox, args)
          element.set(value)
        end
      end

      def flag_reader(name, *args)
        form_field_readers << name
        define_method name do
          element = find_element(:checkbox, args)
          element.checked?
        end
        alias_method :"#{name}?", name
      end

      def flag_accessor(name, *args)
        flag_writer(name, *args)
        flag_reader(name, *args)
      end
      alias flag flag_accessor
    end
  end
end
