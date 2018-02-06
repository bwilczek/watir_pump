# frozen_string_literal: true

require 'watir_pump'

require_relative '../components/top_menu'

class BasePage < WatirPump::Page
  component :top_menu, TopMenu, :div, id: 'top_menu'
  component :top_menu_lambda, TopMenu, -> { browser.div(id: 'top_menu') }
  component :top_menu_lambda_param, TopMenu, ->(id) { browser.div(id: id) }
end
