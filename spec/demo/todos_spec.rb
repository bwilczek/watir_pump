# frozen_string_literal: true

require_relative 'lib/pages/todos_page'

RSpec.describe 'ToDos page' do
  describe 'Welcome modal' do
    it 'opens and closes' do
      ToDosPage.open do
        expect(welcome_modal).not_to be_present
        open_welcome_modal
        expect(welcome_modal).to be_present
        expect(welcome_modal.title).to eq 'Welcome modal'
        expect(welcome_modal.title_reader_element.text).to eq 'Welcome modal'
        expect(welcome_modal.content).to include 'Hello WatirPump!'
        welcome_modal.close
        expect(welcome_modal).not_to be_present
      end
    end
  end

  describe 'dsl' do
    it 'works without passing page to block' do
      ToDosPage.open do
        expect(welcome_modal).not_to be_present
        top_menu.welcome
        expect(browser.title).to include('ToDo')
        expect(welcome_modal).to be_present
      end
    end
  end

  describe 'region' do
    it 'works not nested for watir locator' do
      ToDosPage.open do
        expect(welcome_modal).not_to be_present
        top_menu.welcome
        expect(welcome_modal).to be_present
      end
    end

    it 'works not nested for lambda locator' do
      ToDosPage.open do
        expect(welcome_modal).not_to be_present
        top_menu2.welcome
        expect(welcome_modal).to be_present
      end
    end
  end

  describe 'ToDo lists' do
    it 'is loaded when ToDo lists are present' do
      ToDosPage.open(query: { random_delay: true }) do
        expect(todo_lists).to be_present
      end
    end

    it 'has properly defined page model' do
      ToDosPage.open do
        home_items = todo_lists['Home'].items.map(&:name)
        expect(home_items).to include('Dishes', 'Laundry', 'Vacuum')
      end
    end

    it 'adds item to list' do
      ToDosPage.open(query: { random_delay: true }) do
        home_todo_list = todo_lists['Home']
        home_todo_list.add('Ironing')
        expect(home_todo_list.items.map(&:name)).to include('Ironing')
      end
    end

    it 'removes item from list' do
      ToDosPage.open(query: { random_delay: true }) do
        home_todo_list = todo_lists['Home']
        home_todo_list.remove('Laundry')
        expect(home_todo_list.items.map(&:name)).not_to include('Laundry')
      end
    end

    it 'supports multiple decorations' do
      ToDosPage.open do
        expect(todo_lists.count * 3).to eq todo_lists.count_times_three
      end
    end

    it 'supports decorated watir element collection' do
      ToDosPage.open do
        home_todo_list = todo_lists['Home']
        expect(home_todo_list.items_raw.count * 3).to eq home_todo_list.items_raw.count_times_three
      end
    end
  end
end
