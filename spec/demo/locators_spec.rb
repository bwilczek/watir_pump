# frozen_string_literal: true

require_relative 'lib/pages/index_page'
require_relative 'lib/pages/calculator_page'

RSpec.describe 'Locators on Page' do
  describe 'watir element' do
    it 'found for static watir locator' do
      IndexPage.open do
        expect(cat.attribute_value('alt')).to include('The cat is here')
      end
    end

    it 'found for lambda' do
      IndexPage.open do
        expect(cat_lambda.attribute_value('alt')).to include('The cat is here')
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do
        expect(cat_lambda_param('wilhelmine').attribute_value('alt')).to include('The cat is here')
      end
    end

    it 'raises error when lambda returns element of different type' do
      IndexPage.open do
        expect { cat_image_that_is_a_table }.to raise_error(/does not match/)
      end
    end

    it 'raises error when lambda returns element of different type (collection)' do
      IndexPage.open do
        expect { spans_that_are_divs }.to raise_error(/does not match/)
      end
    end
  end

  describe 'component' do
    it 'found for static watir locator' do
      IndexPage.open do
        top_menu.calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end

    it 'found for lambda' do
      IndexPage.open do
        top_menu_lambda.calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do
        top_menu_lambda_param('top_menu').calculator.click
        expect(browser.url).to include('calculator.html')
      end
    end
  end

  describe 'components' do
    it 'found for static watir locator' do
      IndexPage.open do
        yes0.click
        expect(questions[0].buttons.result.text).to eq 'Yay!'
        yes_n(2).click
        expect(questions[2].buttons.result.text).to eq 'Yay!'
      end
    end

    it 'found for lambda' do
      IndexPage.open do
        yes0.click
        expect(questions_lambda[0].buttons.result.text).to eq 'Yay!'
        yes_n(2).click
        expect(questions_lambda[2].buttons.result.text).to eq 'Yay!'
      end
    end

    it 'found for lambda with param' do
      IndexPage.open do
        yes0.click
        expect(questions_lambda_param('question_wrapper')[0].buttons.result.text).to eq 'Yay!'
        yes_n(2).click
        expect(questions_lambda_param('question_wrapper')[2].buttons.result.text).to eq 'Yay!'
      end
    end
  end

  describe 'query' do
    it 'works without params' do
      IndexPage.open do
        expect(btn_cnt).to eq 6
        expect(cat_alt).to include('The cat is here')
      end
    end

    it 'works with params' do
      IndexPage.open do
        expect(yes_n_query(1)).to be_a Watir::Button
      end
    end
  end
end
