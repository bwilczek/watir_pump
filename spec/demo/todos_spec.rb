require_relative 'lib/pages/todos_page'
require_relative 'lib/helpers/sinatra_helper'

RSpec.describe 'ToDos page' do
  describe 'Welcome modal' do
    it 'opens and closes' do
      ToDosPage.open do |page, _browser|
        expect(page.welcome_modal).not_to be_visible
        page.open_welcome_modal
        expect(page.welcome_modal).to be_visible
        expect(page.welcome_modal.title).to eq 'Welcome modal'
        expect(page.welcome_modal.title_element.text).to eq 'Welcome modal'
        expect(page.welcome_modal.content).to include 'Hello WatirPump!'
        page.welcome_modal.close
        expect(page.welcome_modal).not_to be_visible
      end
    end
  end

  describe 'ToDo lists' do
    it 'is loaded when ToDo lists are present' do
      ToDosPage.open(query: { random_delay: true }) do |page, _browser|
        expect(page.todo_lists).to be_present
      end
    end
  end
end
