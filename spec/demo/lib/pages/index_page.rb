require 'watir_pump'

require_relative '../components/question'
require_relative '../components/top_menu'
require_relative 'base_page'

class IndexPage < BasePage
  uri '/index.html'

  image :cat, id: 'wilhelmine'
  image :cat_lambda, -> { browser.image(id: 'wilhelmine') }
  image :cat_lambda_param, ->(name) { browser.image(id: name) }

  div :questions_box, id: 'questions'

  components :questions, QuestionWidget, :divs, data_role: 'question_wrapper'
  components :questions_lambda, QuestionWidget, -> { questions_box.divs(data_role: 'question_wrapper') }
  components :questions_lambda_param, QuestionWidget, ->(role) { questions_box.divs(data_role: role) }

  dynamic :yes0, -> { yes_n(0) }
  dynamic :yes_n, ->(n) { questions[n].buttons.yes }
  dynamic :cat_alt, -> { cat.attribute_value('alt') }
  dynamic :btn_cnt, -> { questions.sum { |q| q.node.buttons.count } }

  def goto_contact
    top_menu.contact.click
  end
end
