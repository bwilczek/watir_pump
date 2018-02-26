# WORK IN PROGRESS

## this README is not up-to-date

**Table of contents**
* [Introduction](#introduction)
* [Examples](#examples)
    * [Step 1: Just Watir elements](#step-1-just-watir-elements)
    * [Step 2: Make it a component](#step-2-make-it-a-component)
    * [Step 3: Make it more elegant and ready for Ajax](#step-3-make-it-more-elegant-and-ready-for-ajax)
* [Core concepts](#core-concepts)
    * [Configuration](#configuration)
    * [Page](#page)
      * [uri & loaded?](#uri--loaded)
      * [Element and components](#elements-and-components)
      * [Element action macros](#element-action-macros-1)
      * [Interacting with pages](#interacting-with-pages)
    * [Component](#component)
    * [ComponentCollection](#componentcollection)
    * [Decoration](#decoration)

# Introduction

`PageObject` pattern for `Watir`. Heavily inspired by `SitePrism`
and `Watirsome`. Hacker friendly and enterprise ready.

## Key features

#### DSL to describe pages

```ruby
class SeachPage < WatirPump::Page
  text_field :query_input, id: 'query'
  button :search_button, id: 'btnG'
end
```

Class macro methods (here: `text_field`, `button`) act as a proxy to `watir` element locator methods with same names.

#### DSL to interact with pages

```ruby
SearchPage.open do
  query_input.set 'Watir'
  search_button.click
end
```

#### Nestable components

```ruby
class SubComponent < WatirPump::Component
  # some elements
end

class LoginBox < WatirPump::Component
  component :sub, SubComponent, -> { root.div(class: 'resetPassword') }
  text_field :username, id: 'user'
  text_field :password, id: 'pass'
  button :login, id: 'login'
end

class HomePage < WatirPump::Page
  component login_box, LoginBox, -> { root.div(id: 'login_box') }

  def do_login(user, pass)
    login_box.username.set user
    login_box.password.set pass
    login_box.login.click
  end
end
```

#### Regions (anonymous components)

If certain HTML section appears only on one page (thus there's no point in creating another `Component` class)
it can be declared in-place, as a region (anonymous component), which will just act as
a name space in the `Page` object.

```ruby
class HomePage < WatirPump::Page
  region :login_box, :div, id: 'login_box' do
    text_field :username, id: 'user'
    text_field :password, id: 'pass'
    button :login, id: 'login'
  end

  def do_login(user, pass)
    login_box.username.set user
    login_box.password.set pass
    login_box.login.click
  end
end
```

#### Element action macros

```ruby
class LoginPage < WatirPump::Page
  text_field_writer :username, id: 'user'
  text_field_writer :password, id: 'pass'
  button_clicker :login, id: 'login'
end

LoginPage.open do
  username = 'bob'     # same as element.set 'bob'
  password = '$3crEt'  # same as element.set '$3crEt'
  login                # same as element.click
end
```

#### Support for parametrized URLs

```ruby
class SearchResults < WatirPump::Page
  url '/search{/phrase}'
  divs :results, class: 'result-item'
end

SearchResults.open(phrase: 'watir') do
  expect(results.count).to be > 0
end
```

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
Let's encapsulate the elements into a [Component](#component), so that it could be reused
on multiple pages, or even on one page.

Components can be nested, and grouped into `ComponentCollections`.

Additionally in this iteration [element action macros](#element-action-macros-1) are introduced.
Instead of generating methods that return `Watir` elements they perform certain actions at once.

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
  before(:each) { |example| WatirPump.config.current_example = example }
  before :all do
    WatirPump.configure do |c|
      c.base_url = 'http://localhost:4567'
      c.browser = Watir::Browser.new
    end
  end

  it 'adds an item to the "Home" ToDo list' do
    # another way of opening and accessing page
    ToDosPage.open do
      home_todo_list = todo_lists.find { |l| l.title == 'Home' }
      home_todo_list.new_item = 'Ironing'
      home_todo_list.btn_add
      new_items = home_todo_list.items.map(&:name)
      expect(new_items).to include('Ironing')
    end
  end
end
```

## Step 3: Make it more elegant and ready for Ajax

The new concept introduced here is the [query](#query) class macro.

And now the improved example:

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
    ToDosPage.open do
      # possible thanks to decoration of todo_lists in ToDosPage
      home_todo_list = todo_lists['Home']
      home_todo_list.add('Ironing')
      expect(home_todo_list.items).to include('Ironing')
    end
  end
end
```

# Core concepts

## Configuration

`WatirPump` includes `ActiveSupport::Configurable` - a popular concept known from `Rails`.

The following settings are required to start:

```ruby
WatirPump.configure do |c|
  # Self explanatory: Watir::Browser instance
  c.browser = Watir::Browser.new

  # Self explanatory: root URL for the application under test
  c.base_url = 'http://localhost:4567'

  # Flag defining execution context of blocks passed to Page.use and Page.open
  # See 'Interacting with pages'
  #   true  - block is evaluated with yield and accepts |page, browser| arguments
  #   false - block is evaluated with instance_exec on Page (default)
  c.call_page_blocks_with_yield = false
end
```

To make `rspec` work with page DSL the following key has to be set:

```ruby
before(:each) { |example| WatirPump.config.current_example = example }
```

## Page

`Page` class definition consists of a list of class macros invocations.
Most of them are inherited from [Component](#component) class. Few exceptions are:

 * `uri` - the URL part that is relative to `WatirPump.config.base_url`
 * `loaded?` - predicate returning `true` if page is ready to be interacted with. Default implementation checks if current browser URL matches the `uri`

### URI & loaded?

Let's consider the following configuration for the examples below:

```ruby
WatirPump.config.base_url = 'https://myapp.local:8080'
```
#### URI without parameters

```ruby
class ContactPage
  uri "/contact"
end

ContactPage.open
 # => https://myapp.local:8080/contact
```

#### URI with a single parameter

```ruby
class UserPage
  uri "/users{/username}"
end

UserPage.open(username: 'boromir')
 # => https://myapp.local:8080/users/boromir
```

#### URI with a query string
```ruby
class UserPage
  uri "/search{?query*}"
end

SearchPage.open(query: { phrase: 'watir', offset: 50, limit: 100 })
 # => https://myapp.local:8080/search?phrase=watir&offset=50&limit=100
```

#### Customized `loaded?` condition
```ruby
class HeavyReactPage
  uri "/spa"
  query :loaded?, -> { root.div(class: 'ajax-fetched-content').visible? }
end

HeavyReactPage.open do
  # 'This will execute once JS renders the element referenced in loaded? method'
end
 # => https://myapp.local:8080/spa
```

See [addressable gem](https://github.com/sporkmonger/addressable)
for more information about the URL template format.

### Elements and components

* root (vs browser)
* watir methods `Watir::Container`
* lambdas
* lamdbas with parameters

### `query` macro

It is a shorthand to generate simple methods, usually to query DOM tree with Watir. Examples:

```ruby
class SamplePage
  spans :items, class: 'search-result'

  # regular methods
  def items_text
    items.map(&:text)
  end

  def items_cnt
    items.count
  end

  def items_with_substring(phrase)
    items_text.select { |item| item.include? phrase }
  end

  # query class macro equivalent
  query :items_text, -> { items.map(&:text) }
  query :items_cnt, -> { items.count }
  query :items_with_substring ->(phrase) { items_text.select { |item| item.include? phrase } }
end
```

As one can see `query` macro is not specific to Watir, it's just a general purpose shorthand to define methods.

### Element action macros

There are cases where certain page element is used only to perform one action: either click, write into, or read value.
In such case it would be more convenient to have a page object method that would perform that action at once, instead of returning the Watir element.

Element actions macros are design to do just that.

| Declaration in page class                | Element action example              |
|------------------------------------------|-------------------------------------|
| `span :name, id: 'abc'`                  | `n = page.name.text`                |
| `span_reader :name, id: 'abc'`           | `n = page.name`                     |
| `link :goto_contacts, id: 'abc'`         | `page.goto_contacts.click`          |
| `link_clicker :goto_contacts, id: 'abc'` | `page.goto_contacts`                |
| `text_field :email, id: 'abc'`           | `page.email.set 'john@example.com'` |
| `text_field_writer :email, id: 'abc'`    | `page.email = 'john@example.com'`   |

How it internally works?

Macro `span_reader :article_title, id: 'title'` creates two public methods:

 * `article_title_element` which returns Watir element `:span, id: 'title'`
 * `article_title` which returns `article_title_element.text`

Macros `*_clicker` and `*_writer` follow the same convention: additional `_element` method is created next to the action method.

Full list of tags supported by certain action macros can be found in [WatirPump::Constants](lib/watir_pump/constants.rb).

### Interacting with pages

Let's consider the following pages (simplified declaration):

```ruby
class SearchFormPage < WatirPump::Page
  uri '/search'
  text_field :phrase, id: 'q'
  button :search, id: 'btnG'

  def do_search(query)
    phrase.set query
    search.click
    SearchResultsPage.new.wait_for_loaded
  end  
end

class SearchResultsPage < WatirPump::Page
  uri '/results'
  divs :results, class: 'result-item'
end
```

There are three ways that page objects can be interacted with.

#### 1. DSL like style

Block is evaluated in scope of the `Page` object.
Looks nice (no need to type 'page.') but methods visible in the spec
are not visible in the block. The only exception are the `RSpec` methods.

```ruby
WatirPump.config.call_page_blocks_with_yield = false # this is default

# this is required to make rspec expectations work inside the block
before(:each) { |example| WatirPump.config.current_example = example }

ToDosPage.open do
  phrase.set 'watir'
  search.click
end
SearchResultsPage.use do
  expect(results.cnt).to be > 0
end
```

**IMPORTANT NOTICE:** This won't work:
```ruby
def helper
  fancy_logic
end

ToDosPage.open do
  phrase.set 'watir'
  helper # Error: Method is undefined in this scope.
  search.click
end
```

Use rspec's `let` instead:
```ruby
let(:helper) { fancy_logic }

ToDosPage.open do
  phrase.set 'watir'
  helper # 3. profit
  search.click
end
```

#### 2. A regular yield

A regular block. `page` and `browser` references are passed as parameters to the block

```ruby
WatirPump.config.call_page_blocks_with_yield = true

ToDosPage.open do |page, _browser|
  page.phrase.set 'watir'
  page.search.click
end
SearchResultsPage.use do |page, browser|
  expect(page.results.cnt).to be > 0
  expect(browser.title) to include 'Results'
end
```

#### So how it works internally?

Internally Page.open/Page.use methods uses one of:
```ruby
Page.open_yield Page.use_yield
Page.open_dsl   Page.use_dsl
```
depending on the value of config field `call_page_blocks_with_yield`.
These methods can be called directly if there is a need to mix the approaches.

#### 3. No magic, the regular Page Object Pattern way

```ruby
page = ToDosPage.new(browser)
page.phrase.set 'watir'
page.search.click
page = SearchResultsPage.new(browser)
expect(page.results.cnt).to be > 0

# or more elegantly:
search_page = ToDosPage.new(browser)
results_page = search_page.do_search('watir')
expect(results_page.results.cnt).to be > 0
```

## Component

_under construction_

* `browser` - reference to `Watir::Browser` instances
* `root` (alias: `node`)
* `parent`
* can be nested
* class macros for list of page elements, or sub-components

## Region aka anonymous component

_under construction_

## ComponentCollection

_under construction_

## Decoration

_under construction_

```ruby
# decorator class for component collections should extend WatirPump::ComponentCollection
decorate :todo_lists, ToDoListCollection, DummyDecoratedCollection

# decorator class for elements should extend WatirPump::DecoratedElement
decorate :btn_add, DummyDecoratedElement
```
