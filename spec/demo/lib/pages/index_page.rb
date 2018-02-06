# frozen_string_literal: true

require 'watir_pump'

require_relative '../components/question_widget'
require_relative '../components/top_menu'
require_relative '../components/product_table'
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

  component :products, ProductTable, :table, id: 'products'

  button :yes0, -> { yes_n(0) }
  button :yes_n, ->(n) { questions[n].buttons.yes }
  query :yes_n_query, ->(n) { questions[n].buttons.yes }
  query :cat_alt, -> { cat.attribute_value('alt') }
  query :btn_cnt, -> { questions.sum { |q| q.node.buttons.count } }

  def goto_contact
    top_menu.contact.click
  end
end
