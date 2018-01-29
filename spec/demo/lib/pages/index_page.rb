require 'watir_pump'
require 'pry'

require_relative '../components/question'
require_relative '../components/top_menu'

class IndexPage < WatirPump::Page
  uri '/index.html'

  component :top_menu, TopMenu, :div, id: 'top_menu'
  components :questions, QuestionWidget, :divs, data_role: 'question_wrapper'
end
