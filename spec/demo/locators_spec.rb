require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'Locators on Page' do
  describe 'watir element' do
    it 'found for static watir locator' do
      IndexPage.open do |page, _browser|
        expect(page.cat.attribute_value('alt')).to include('The cat is here')
      end
    end

    it 'found for lambda' do
      IndexPage.open do |page, _browser|
        expect(page.cat_lambda.attribute_value('alt')).to include('The cat is here')
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do |page, _browser|
        expect(page.cat_lambda_param('wilhelmine').attribute_value('alt')).to include('The cat is here')
      end
    end
  end

  describe 'component' do
    it 'found for static watir locator' do
      IndexPage.open do |page, browser|
        page.top_menu.calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end

    it 'found for lambda' do
      IndexPage.open do |page, browser|
        page.top_menu_lambda.calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do |page, browser|
        page.top_menu_lambda_param('top_menu').calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end
  end

  describe 'components' do
    it 'found for static watir locator' do
      IndexPage.open do |page, _browser|
        page.yes0.click
        expect(page.questions[0].buttons.result.text).to eq 'Yay!'
        page.yes_n(2).click
        expect(page.questions[2].buttons.result.text).to eq 'Yay!'
      end
    end

    it 'found for lambda' do
      IndexPage.open do |page, _browser|
        page.yes0.click
        expect(page.questions_lambda[0].buttons.result.text).to eq 'Yay!'
        page.yes_n(2).click
        expect(page.questions_lambda[2].buttons.result.text).to eq 'Yay!'
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do |page, _browser|
        page.yes0.click
        expect(page.questions_lambda_param('question_wrapper')[0].buttons.result.text).to eq 'Yay!'
        page.yes_n(2).click
        expect(page.questions_lambda_param('question_wrapper')[2].buttons.result.text).to eq 'Yay!'
      end
    end
  end

  describe 'query' do
    it 'works without params' do
      IndexPage.open do |page, _browser|
        expect(page.btn_cnt).to eq 6
        expect(page.cat_alt).to include('The cat is here')
      end
    end

    it 'works with params' do
      IndexPage.open do |page, _browser|
        expect(page.yes_n_query(1)).to be_a Watir::Button
      end
    end
  end
end
