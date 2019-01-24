# frozen_string_literal: true

module WatirPump
  module Components
    module CheckboxGroup
      def checkbox_writer(name, *args) # rubocop:disable Metrics/AbcSize
        form_field_writers << name
        define_method "#{name}=" do |values|
          values = Array(values)
          # <label>value<input /></label>
          list = find_element(:checkboxes, args)
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
        form_field_readers << name
        define_method name do
          selected = find_element(:checkboxes, args).select(&:set?)
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
      alias checkbox_group checkbox_accessor
    end
  end
end
