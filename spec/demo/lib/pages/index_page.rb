require 'watir_pump'
require 'pry'

require_relative '../components/question'
require_relative '../components/top_menu'

class IndexPage < WatirPump::Page
  uri '/index.html'

  image :cat, id: 'wilhelmine'
  component :top_menu, TopMenu, :div, id: 'top_menu'
  components :questions, QuestionWidget, :divs, data_role: 'question_wrapper'
  dynamic :yes0, -> { yes_n(0) }
  dynamic :yes_n, ->(n) { questions[n].buttons.yes }
  dynamic :cat_alt, -> { cat.attribute_value('alt') }
  dynamic :btn_cnt, -> { questions.sum { |q| q.node.buttons.count } }
end
