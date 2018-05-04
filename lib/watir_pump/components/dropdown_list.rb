# frozen_string_literal: true

module WatirPump
  module Components
    module DropdownList
      def select_reader(name, *args)
        form_field_readers << name
        define_method(name) do
          select = find_element(:select, args)
          selected = select.selected_options
          return select.multiple? ? selected.map(&:text) : selected.first.text
        end
      end

      def select_writer(name, *args)
        form_field_writers << name
        define_method("#{name}=") do |values|
          select = find_element(:select, args)
          return select.select(*values)
        end
      end

      def select_accessor(name, *args)
        select_reader(name, *args)
        select_writer(name, *args)
      end
      alias dropdown_list select_accessor
    end
  end
end
