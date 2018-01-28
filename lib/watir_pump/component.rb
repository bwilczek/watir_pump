module WatirPump
  class Component
    class << self
      %w[text_field button title span div].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            browser.send(watir_method, *args, **keyword_args)
          end
        end
      end
    end
  end
end
