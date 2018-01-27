require 'watir'
require 'active_support/configurable'

module WatirPump
  include ActiveSupport::Configurable

  class Page
    attr_reader :browser

    class << self
      def uri(uri = nil)
        @uri = uri unless uri.nil?
        @uri
      end

      def open(&blk)
        instance.instance_eval do
          browser.goto WatirPump.config.base_url + uri
        end
        use(&blk) if block_given?
      end

      def use(&blk)
        instance.instance_eval(&blk)
      end

      def instance
        @instance ||= new(WatirPump.config.browser)
      end

      %w[text_field button title].each do |watir_method|
        define_method watir_method do |name, *args, **keyword_args|
          define_method(name) do
            browser.send(watir_method, *args, **keyword_args)
          end
        end
      end
    end

    # def text_field(name, *args)
    #   define_method(name) do |*method_args, **method_named_args|
    #     browser.text_field(*args)
    #   end
    # end

    def initialize(browser)
      @browser = browser
    end

    def uri
      self.class.uri
    end
  end
end

class HomePage < WatirPump::Page
  uri '/'
  text_field :inbox, id: 'inboxfield'
  button :submit, text: 'Go!'

  def goto_inbox(inbox_name)
    inbox.set inbox_name
    submit.click
    submit.wait_while_present
  end
end

class InboxPage < WatirPump::Page
  text_field :inbox, id: 'inbox_field'
end

WatirPump.configure do |c|
  c.browser = Watir::Browser.new
  c.base_url = 'https://www.mailinator.com'
end

HomePage.open { goto_inbox('kasia') }
InboxPage.use do
  inbox.set 'Kazimiera'
  puts browser.title
  sleep 5
end
