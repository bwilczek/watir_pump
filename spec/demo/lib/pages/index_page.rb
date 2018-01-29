require 'watir_pump'

require_relative '../components/yes_no_widget'

class IndexPage < WatirPump::Page
  uri '/index.html'

  component :yes_no, YesNoWidget, :div, id: 'reusable_component'
end
