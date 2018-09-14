# frozen_string_literal: true

require 'active_support/core_ext/string'

module WatirPump
  WATIR_METHOD_MAPPING = Watir.tag_to_class.dup
  Watir.tag_to_class.each do |tag, klass|
    tags = tag.to_s.pluralize.to_sym
    klasses = "#{klass}Collection".safe_constantize
    WATIR_METHOD_MAPPING[tags] = klasses if klasses
  end
  WATIR_METHOD_MAPPING[:image] = Watir::Image
  WATIR_METHOD_MAPPING[:images] = Watir::ImageCollection
  WATIR_METHOD_MAPPING[:link] = Watir::Anchor
  WATIR_METHOD_MAPPING[:links] = Watir::AnchorCollection
  WATIR_METHOD_MAPPING[:text_field] = Watir::TextField
  WATIR_METHOD_MAPPING[:text_fields] = Watir::TextFieldCollection
  WATIR_METHOD_MAPPING[:select_list] = Watir::Select
  WATIR_METHOD_MAPPING[:select_lists] = Watir::SelectCollection
  WATIR_METHOD_MAPPING[:field_set] = Watir::FieldSet
  WATIR_METHOD_MAPPING[:field_sets] = Watir::FieldSetCollection
  WATIR_METHOD_MAPPING[:radio] = Watir::Radio
  WATIR_METHOD_MAPPING[:radios] = Watir::RadioCollection
  WATIR_METHOD_MAPPING[:checkbox] = Watir::CheckBox
  WATIR_METHOD_MAPPING[:checkboxes] = Watir::CheckBoxCollection
  WATIR_METHOD_MAPPING[:frame] = Watir::Frame
  WATIR_METHOD_MAPPING[:frames] = Watir::FrameCollection
  WATIR_METHOD_MAPPING[:file_field] = Watir::FileField
  WATIR_METHOD_MAPPING[:file_fields] = Watir::FileFieldCollection
  WATIR_METHOD_MAPPING[:hidden] = Watir::Hidden
  WATIR_METHOD_MAPPING[:hiddens] = Watir::HiddenCollection
  WATIR_METHOD_MAPPING[:font] = Watir::Font
  WATIR_METHOD_MAPPING[:fonts] = Watir::FontCollection

  WATIR_METHOD_MAPPING.freeze
end
