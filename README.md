# WatirPump

`WatirPump` is a `Page Object` pattern implementation for `Watir`. Hacker friendly and enterprise ready.
Heavily inspired by `SitePrism` and `Watirsome`.

### To learn WatirPump by example please refer to [THIS TUTORIAL](https://github.com/bwilczek/watir_pump_tutorial)

**Table of contents**
* [Key features](#key-features)
* [Examples](#examples)
    * [Step 1: Just Watir elements](#step-1-just-watir-elements)
    * [Step 2: Make it a component](#step-2-make-it-a-component)
    * [Step 3: Make it more elegant and ready for Ajax](#step-3-make-it-more-elegant-and-ready-for-ajax)
* [Documentation](#documentation)
    * [Installation](#installation)
    * [Configuration](#configuration)
    * [Page](#page)
      * [uri & loaded?](#uri--loaded)
      * [Interacting with pages](#interacting-with-pages)
        * [1. DSL like style](#1-dsl-like-style)
        * [2. A regular yield](#2-a-regular-yield)
        * [3. No magic, the regular Page Object pattern way](#3-no-magic-the-regular-page-object-pattern-way)
    * [Component](#component)
      * [Instance methods](#instance-methods)
      * [Declaring elements and subcomponents with class macros](#declaring-elements-and-subcomponents-with-class-macros)
        * [Elements](#elements)
        * [Subcomponents](#subcomponents)
        * [Locating elements and subcomponents](#locating-elements-and-subcomponents)
      * [Query class macro](#query-class-macro)
      * [Element action macros](#element-action-macros-1)
      * [Form helpers](#form-helpers)
    * [Region aka anonymous component](#region-aka-anonymous-component)
    * [ComponentCollection](#componentcollection)
    * [Decoration](#decoration)

### To learn WatirPump by example please refer to [THIS TUTORIAL](https://github.com/bwilczek/watir_pump_tutorial)

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

#### Helpers for forms ####

```ruby
class NewProductPage < WatirPump::Page
  text_field_writer :name, id: 'name'
  text_field_writer :quantity, id: 'qty'
  button_clicker :submit, id: 'add'
end

class ShowProductPage < WatirPump::Page
  span_reader :name, id: 'name'
  span_reader :quantity, id: 'qty'
end

RSpec.describe 'product creation' do
  let(:data) { { name: 'Hammer XT-431', quantity: 500 } }

  it 'saves product' do
    NewProductPage.open do
      fill_form(data)
      submit
    end
    ShowProductPage.use do
      expect(form_data).to eq data
    end
  end
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

Imagine a page that contains three ToDo lists. Or maybe instead of imagining just clone this repo and
open `sinatra_app/public/todos.html` in your browser. This page will serve
as an example of how one can model and test pages using `WatirPump`.

The HTML code representing a single `ToDo` list can look like this:

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
  # expose shorter method name to return just array of strings
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

# Documentation

## Installation

Just like with any other `gem`:

Directly:
```
gem install watir_pump
```

or via `Gemfile` + `bundle install`
```
gem 'watir_pump', '~>0.2'
```

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

For information about how to declare elements and component for the `Page` please go to [Component](#component) section.
Internally `Page` itself is a `Component`, that holds other components and Watir elements (components are nestable).

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
    SearchResultsPage.new(browser).wait_for_loaded
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
def search_term
  'watir'
end

ToDosPage.open do
  phrase.set search_term
  # Error: Method search_term is undefined in this scope.
  search.click
end
```

Use rspec's `let` instead:
```ruby
let(:search_term) { 'watir' }

ToDosPage.open do
  phrase.set search_term
  # now it works
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

Internally `Page.open`/`Page.use` methods uses one of:
```ruby
Page.open_yield Page.use_yield
Page.open_dsl   Page.use_dsl
```
depending on the value of config field `call_page_blocks_with_yield`.
These methods can be called directly if there is a need to mix the approaches.

#### use vs open

```ruby
MyPage.open { block }
# browser navigates to page's uri before executing the block

MyPage.use { block }
# block is executed once page is loaded. No browser.goto called internally
# use has an alias method called act
```

#### 3. No magic, the regular Page Object pattern way

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

Component is the core concept of `WatirPump` page object model definition.
It provides a set of class macros and regular instance methods that make creation of
such model easy.

### Instance methods

* `browser` - reference to `Watir::Browser` instance
* `root` (alias: `node`) - reference to `Watir::Element`: component's 'mounting point' inside the DOM tree. (WARNING: for `Pages` it refers to `browser`)
* `parent` - reference to parent component (`nil` for `Pages`)

### Declaring elements and subcomponents with class macros

#### Elements

Declaration of simple HTML/Watir elements is easy. Every instance method of [Watir::Container](http://www.rubydoc.info/gems/watir-webdriver/Watir/Container) module
is exposed to `WatirPump::Component` as a class macro method.

Examples:

```ruby
class MyPage < WatirPump::Page
  link :index, href: /index/
  # equivalent of:
  def index
    browser.link href: /index/
    # more WatirPump like notation would be to use root instead of browser:
    # root.link href: /index/
  end
  # usage: page.index.click

  button :ok, value: 'OK'
  # equivalent of:
  def ok
    root.button value: 'OK'
  end
  # usage: page.ok.click

  button :action, ->(val) { root.button(value: val) }
  # equivalent of:
  def action(val)
    root.button(value: val)
  end
  # usage: page.action('Confirm').click
end
```

Fore more examples see [Watir guides](http://watir.com/guides/elements/).

#### Subcomponents

There are two class macros: `component` and `components` that are used to declare a single subcomponent, or a collection.

Synopsis:

```
component :name, ComponentClass, <locator_for_single_node>
components :name, ComponentClass, <locator_for_multiple_nodes>
```

Examples:

```ruby
class LoginBox < WatirPump::Components
  button :login, id: 'btn_login'
end

class MyPage < WatirPump::Page
  component :login_box, LoginBox, :div, id: 'login_box'
  # usage: page.login_box.login.click

  components :results, SearchResultItem, :divs, class: 'login_box'
  # usage: page.results.count
end
```

For other ways of locating elements (using lambdas and parametrized lambdas) see below.

#### Others

Other macros, like `query`, `region` and `component actions` are documented in the following paragraphs.

#### Locating elements and subcomponents

There are two ways of defining location of subcomponents within the current component (or page). Both are relative to current component's `root`.
Location used in declaration of a subcomponent (invocation of `componenet` class macro) will be the `root`  of that subcomponent.

The parent component reference is accessible through `parent` method.

##### The Watir way

For complete list of elements supported this way please see [Watir::Container](http://www.rubydoc.info/gems/watir-webdriver/Watir/Container).

Synopsis:

```
component <name>, <component_class>, <watir_method_name>, <watir_method_params_optionally>
```

Examples:

```ruby
# component class LoginBox, instance name login_box, located under root.div(id: 'login_box')
component :login_box, LoginBox, :div, id: 'login_box'
# example usage: page.login_box.wait_until_present

# component class ArticleParagraph, instance name paragraph, located under root.p
component :paragraph, ArticleParagraph, :p
# example usage: page.paragraph.visible?
```

##### Lambdas

Examples:

```ruby
# component class LoginBox, instance name login_box, located under root.div(id: 'login_box')
component :login_box, LoginBox, -> { root.div(id: 'login_box') }

# component class ArticleParagraph, instance name paragraph, located under root.p(id: <passed as an argument>)
component :paragraph, ArticleParagraph, ->(cls) { root.p(id: cls) }
# example usage: page.paragraph('abstract').text
```

##### root vs browser

For top level components (pages) both `root.div(class: 'asd')` and `browser.div(class: 'asd')` would work the same.
This is because `root` of every `Page` is `browser`. For subcomponents however `root` points to node
which is the mounting point of the component in the DOM tree.

Using `root` as a base for locating elements is recommended as a more robust convention.

Use `browser` to interact with the browser itself (cookies, navigation, javascript, title, etc.). NOT to navigate DOM.

##### Example

Let's consider the following Page structure:

```ruby
class MyPage < WatirPump::Page
  component :login_box, LoginBox, :div, id: 'login_box'
end

class LoginBox < WatirPump::Component
  component :reset_password, ResetPassword, -> { root.div(class: 'reset-password') }
end

class ResetPassword < WatirPump::Component
  button :send_link, class: 'send-link'
end
```

This is how certain elements/components are located:

```ruby
page = MyPage.new(browser)
page.root
 # => browser.body

page.login_box.root
 # => browser.div(id: 'login_box')

page.login_box.reset_password.root
 # => browser.div(id: 'login_box').div(class: 'reset-password')

page.login_box.reset_password.parent
 # => page.login_box

page.login_box.reset_password.send_link
 # => browser.div(id: 'login_box').div(class: 'reset-password').button(class: 'send-link')
```

### `query` class macro

It is a shorthand to generate simple methods, usually to query DOM tree with Watir. Examples:

```ruby
class SamplePage < WatirPump::Page
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

  # more examples: watir methods can be chained
  query :nested_watir_element ->  { root.form(id: 'new_item').button(class: 'reset_count') }
end
```

As one can see `query` macro is not specific to Watir, it's just a general purpose shorthand to define methods.

`query` has two decorated variants:
 * `element` - raises error if value returned from `query` is not a `Watir::Element`
 * `elements` - raises error if value returned from `query` is not a `Watir::ElementCollection`
 One can use them to declare page objects in `watir-drops` style.

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

 * `article_title_reader_element` which returns Watir element `:span, id: 'title'`
 * `article_title` which returns `article_title_reader_element.text`

**WARNING:** radios, checkboxes and select lists (dropdowns) are handled slightly differently. See below.

Macros `*_clicker` and `*_writer` follow the same convention: additional `_(clicker|writer)_element` method is created next to the action method.

Full list of tags supported by certain action macros can be found in [WatirPump::Constants](lib/watir_pump/constants.rb).

Keep in mind that `writers` cannot rely on element location using parametrized lambda. `field('Employee')="John"` just won't work.

In order to create both `reader` and `writer` for the same element one can use `_accessor` macro.

#### radio_group, checkbox_group, flag, dropdown_list

Radios, checkboxes and selects require special handling because they don't represent a single HTML element, but several of them. For example:

```html
<fieldset>
  <div>Predicate</div>
  <label>Yes<input type="radio" name="predicate" value="yes" /></label>
  <label>No<input type="radio" name="predicate" value="no" /></label>
</fieldset>
<!-- There are two radio buttons that describe values for one form field `predicate`. -->
```

There's a handful of macros to describe such fields in our page objects:

```ruby
class UserFormPage < WatirPump::Page
  # input(name: 'gender') matches a collection of radio elements
  radio_reader :gender, name: 'gender'
  radio_writer :gender, name: 'gender'
  radio_accessor :gender, name: 'gender' # alias: radio_group, combined radio_reader and radio_writer
  # page.gender = 'Female' will click the radio button with a corresponding label (NOT value)
  # page.gender will return 'Female'

  # input(name: 'hobbies[]') matches a collection of checkbox elements
  checkbox_reader :hobbies, name: 'hobbies[]'
  checkbox_writer :hobbies, name: 'hobbies[]'
  checkbox_accessor :hobbies, name: 'hobbies[]' # alias: checkbox_group, combined checkbox_reader and checkbox_writer
  # page.hobbies = 'Yoga' will tick the checkbox with the corresponding label (NOT value)
  # page.hobbies = ['Yoga', 'Music'] sets multiple values
  # page.hobbies will return an array of ticked values

  # input(name: 'confirmed') matches a single checkbox element
  flag_writer :confirmed, name: 'confirmed'
  flag_reader :confirmed, name: 'confirmed'
  flag_accessor :confirmed, name: 'confirmed' # alias: flag, combined flag_writer and flag_reader
  # page.confirmed = true will tick the checkbox
  # page.confirmed will return a boolean with the `checked` status of the element
  # page.confirmed? - same as above

  # select(name: 'ingredients[]') matches a select element
  select_reader :ingredients, name: 'ingredients[]'
  select_writer :ingredients, name: 'ingredients[]'
  select_accessor :ingredients, name: 'ingredients[]' # alias: dropdown_list, combined select_reader and select_writer
  # page.ingredients = 'Salt' will select option with a respective label (NOT value)
  # page.ingredients = ['Salt', 'Oregano'] will select multiple options with respective labels, if select is declared as multiple
  # page.ingredients will return a selected option (single or multiple - depending on 'multiple' attribute of the select element)
end
```

#### Custom readers and writers

Whenever reading or writing value for given form field is more sophisticated than just simple interaction with one HTML element
`custom_reader` and `custom_writer` come handy. Let's consider that a value for certain field should be an array, and the HTML code
that represents it looks like this:

```html
<ul id="hobbies">
  <li>Gardening</li>
  <li>Dancing</li>
  <li>Golf</li>
</ul>
```

There are two ways `custom_reader` for this field could be created:

```ruby
# 1. for one-liners passing a lambda to the class macro invocation will suffice
custom_reader :hobbies, -> { root.ul(id: 'hobbies')&.lis&.map(&:text) || [] }

# 2. for more sophisticated cases use class macro to declare that certain instance method should be treated as a reader
custom_reader :hobbies

def hobbies
  # lots of other code if necessary
  root.ul(id: 'hobbies')&.lis&.map(&:text) || [] }
end

# page.hobbies == ['Gardening', 'Dancing', 'Golf']
```

Same principles apply for `custom_writer`. Let's rewrite the default `text_field_writer` using `custom_writer` as an example.

```ruby
# 1. for one-liner use lambda
custom_writer :first_name, ->(val) { root.text_field(name: 'first_name').set(val) }

# 2. for more complex writer logic use a separate method. NOTE the '=' in method name!
custom_writer :first_name

def first_name=(val)
  # do some fancy logic here if necessary
  root.text_field(name: 'first_name').set(val)
end
```

### Form helpers

`fill_form(data)` - invokes `writer` method for every key of the `data` hash (or struct), with associated value as a parameter. Example:

```ruby
fill_form(name: 'Bob', surname: 'Williams', age: 34)
# is equivalent of
self.name = 'Bob'
self.surname = 'Williams'
self.age = 34
```

`fill_form!(data)` - invokes `fill_form(data)` and additionally `submit` method if it exists (otherwise it raises an exception).

`form_data` - returns a hash of values of all elements that have a `_reader` declared. Example:

```ruby
class UserFormPage < WatirPump::Page
  span_reader :name, id: 'name'
  span_reader :surname, id: 'surname'
  span_reader :age, id: 'age'
end

UserFormPage.open do
  expect(form_data).to contain_exactly(name: 'Bob', surname: 'Williams', age: 34)
end
```

### Forwarding to root

There's a few methods that components forward directly to its root:

* visible?
* present?
* stale?
* wait_until_present
* wait_while_present
* wait_until
* wait_while
* flash

Thanks to this one can write just `comp.present?` instead of `comp.root.present?`.

## Region aka anonymous component

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

`region` class macro accepts the following parameters:

 * name of region
 * root node [locator](#locating-elements-and-subcomponents)
 * block with group of elements/subcomponents

## ComponentCollection

`ComponentCollection` is a wrapper for collection of components. For example: a list of search results. See [Subcomponents](#subcomponents) for an example.

Basically it's an array, with few extra methods that return true if any of the collection items return true.

The example methods are:

```
visible?
present?
wait_until_present
wait_while_present
```

The complete list lives in `WatirPump::Constants::METHODS_FORWARDED_TO_ROOT`.

## Decoration

_under construction_

How it works:

```ruby
decorate :method_to_decorate, DecoratorClass, AnotherDecoratorClasses
```

New `method_to_decorate` is created this way (simplified):

```ruby
def method_to_decorate
  AnotherDecoratorClasses.new(
    DecoratorClass.new(
      old_method_to_decorate
    )
  )
end
```

See [this example](#step-3-make-it-more-elegant-and-ready-for-ajax): class `ToDoListCollection` and invocation of `decorate` macro.

```ruby
# decorator class for component/element collections should extend WatirPump::ComponentCollection
decorate :todo_lists, ToDoListCollection, DummyDecoratedCollection

# decorator class for elements should extend WatirPump::DecoratedElement
decorate :btn_add, DummyDecoratedElement
```
