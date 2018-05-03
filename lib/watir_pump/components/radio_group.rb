# frozen_string_literal: true

module WatirPump
  module Components
    module RadioGroup
      def radio_reader(name, *args)
        define_method name do |*loc_args|
          @form_fields << name
          list = find_element(:radios, args, loc_args)
          selected = list.find(&:set?)
          if selected
            return selected.parent.text if selected&.parent&.tag_name == 'label'
            return root.label(for: selected.id).text
          end
        end
      end

      def radio_writer(name, *args) # rubocop:disable Metrics/AbcSize
        define_method "#{name}=" do |value|
          @form_fields << name
          list = find_element(:radios, args)
          # <label>value<input /></label>
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
      alias radio_group radio_accessor
    end
  end
end
