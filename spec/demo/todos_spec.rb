# frozen_string_literal: true

require_relative 'lib/pages/todos_page'

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

    it 'has properly defined page model' do
      ToDosPage.open do |page, _browser|
        home_items = page.todo_lists['Home'].items.map(&:name)
        expect(home_items).to include('Dishes', 'Laundry', 'Vacuum')
      end
    end

    it 'adds item to list' do
      ToDosPage.open(query: { random_delay: true }) do |page, _browser|
        home_todo_list = page.todo_lists['Home']
        home_todo_list.add('Ironing')
        expect(home_todo_list.items.map(&:name)).to include('Ironing')
      end
    end

    it 'removes item from list' do
      ToDosPage.open(query: { random_delay: true }) do |page, _browser|
        home_todo_list = page.todo_lists['Home']
        home_todo_list.remove('Laundry')
        expect(home_todo_list.items.map(&:name)).not_to include('Laundry')
      end
    end
  end
end
