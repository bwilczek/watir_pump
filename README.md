**Table of contents**
* [Introduction](#introduction)
* [Examples](#examples)
    * [Step 1: Just Watir elements](#step-1-just-watir-elements)
    * [Step 2: Make it a component](#step-2-make-it-a-component)
    * [Step 3: Make it more elegant and ready for Ajax](#step-3-make-it-more-elegant-and-ready-for-ajax)
* [Core concepts](#core-concepts)

# Introduction

Another approach to `PageObject` pattern for `Watir`. Heavily inspired by `SitePrism`
and `Watirsome`.

# Examples

Imagine a page that contains three ToDo lists. Or maybe just clone this repo and
open `sinatra_app/public/todos.html` in your browser instead. This page will serve
as an example of how one can model and test pages using `WatirPump`.

The HTML representing a single ToDo list can look like this:

```html
<div id="todos_home" role="todo_list">
  <div role="title">Home</div>
  <input role="new_item" /><button role="add">Add</button>
  <ul>
    <li><span role="name">Dishes</span><a role="rm">[rm]</a></li>
    <li><span role="name">Laundry</span><a role="rm">[rm]</a></li>
    <li><span role="name">Vacuum</span><a role="rm">[rm]</a></li>
  </ul>
</div>
```

## Step 1: Just Watir elements

For the sake of simplicity let's focus on just one ToDo list for the start.

```ruby
class ToDosPage < WatirPump::Page
  uri '/todos.html'
  # Watir equivalent: browser.div(role: 'title')
  div :title, role: 'title'
  # similarly:
  text_field :new_item, role: 'new_item'
  button :add, role: 'add'
  lis :items, role: 'name'
end

RSpec.describe ToDosPage do
  let(:browser) { Watir::Browser.new }
  let(:page) { ToDosPage.new(browser).open }
  before(:all) { WatirPump.config.base_url = 'http://localhost:4567' }

  it 'adds an item to the "Home" ToDo list' do
    page.new_item.set 'Ironing'
    page.add.click
    new_items = items.map { |li| li.span(role: 'name').text }
    expect(new_items).to include('Ironing')
  end
end
```

## Step 2: Make it a component

The previous example works fine for a page containing just one ToDo list.
Let's encapsulate the elements into a `Component`, so that it could be reused
on multiple pages, or even on one page.

Components can be nested, and grouped into `ComponentCollections`.

Additionally in this iteration constructs of `_reader`, `_writer` and `_clicker`
are introduced. Instead of generating methods that return `Watir` elements they
perform certain actions at once.

| Declaration in page class | usage |
|-------------|-------|
| `span :name, id: 'abc'` | `n = page.name.text` |
| `span_reader :name, id: 'abc'` | `n = page.name` |
| `link :goto_contacts, id: 'abc'` | `page.goto_contacts.click` |
| `link_clicker :goto_contacts, id: 'abc'` | `page.goto_contacts` |
| `text_field :email, id: 'abc'` | `page.email.set 'john@example.com'` |
| `text_field_writer :email, id: 'abc'` | `page.email = 'john@example.com'` |

```ruby
class ToDoList < WatirPump::Component
  div_reader :title, role: 'title'
  text_field_writer :new_item, role: 'new_item'
  button_clicker :btn_add, role: 'add'
  components :items, ToDoListItem, :lis
end

class ToDoListItem < WatirPump::Component
  link_clicker :rm, role: 'rm'
  span_reader :name, role: 'name'
end

class ToDosPage < WatirPump::Page
  uri '/todos.html'
  # page contains several ToDo lists (an Array)
  components :todo_lists, ToDoList, :divs, role: 'todo_list'
end

RSpec.describe ToDosPage do
  before :all do
    WatirPump.configure do |c|
      c.base_url = 'http://localhost:4567'
      c.browser = Watir::Browser.new
    end
  end

  it 'adds an item to the "Home" ToDo list' do
    # another way of opening and accessing page
    ToDosPage.open do |page|
      home_todo_list = page.todo_lists.find { |l| l.title == 'Home' }
      home_todo_list.new_item = 'Ironing'
      home_todo_list.btn_add
      new_items = home_todo_list.items.map(&:name)
      expect(new_items).to include('Ironing')
    end
  end
end
```

## Step 3: Make it more elegant and ready for Ajax

`query`

```ruby
# ToDoListItem stays same as before

class ToDoList < WatirPump::Component
  div_reader :title, role: 'title'
  text_field_writer :new_item, role: 'new_item'
  button_clicker :btn_add, role: 'add'
  # use array of Watir elements internally
  components :item_elements, ToDoListItem, :lis
  # expose shorter name to return just array of strings
  query :items, -> { item_elements.map(&:name) }

  def items_alternative
    # another way to return items, class macro query is just nicer
    item_elements.map(&:name)
  end

  def add(item)
    cnt_before = item_elements.count
    # mind the self. without it a local variable will be crated
    self.new_item = text
    btn_add
    # assume that the addition is performed over an Ajax call
    Watir::Wait.until { item_elements.count == cnt_before + 1 }
  end
end

class ToDoListCollection < WatirPump::ComponentCollection
  def [](title)
    find { |l| l.title == title }
  end
end

class ToDosPage < WatirPump::Page
  uri '/todos.html'
  # Page will declare itself loaded once todo_lists are present
  query :loaded?, -> { todo_lists.present? }
  components :todo_lists, ToDoList, :divs, role: 'todo_list'
  decorate :todo_lists, ToDoListCollection
end

RSpec.describe ToDosPage do
  # setup omitted for brevity

  it 'adds an item to the "Home" ToDo list' do
    ToDosPage.open do |page|
      # possible thanks to decoration of todo_lists in ToDosPage
      home_todo_list = page.todo_lists['Home']
      home_todo_list.add('Ironing')
      expect(home_todo_list.items).to include('Ironing')
    end
  end
end
```

# Core concepts

## Configuration

## Page

## Addressing elements/components

* watir methods
* lambdas
* lamdbas with parameters

## Component

## ComponentCollection
