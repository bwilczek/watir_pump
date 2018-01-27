require 'watir_pump'

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

RSpec.describe 'Mailinator' do
  it 'more-less works' do
    title = nil
    HomePage.open { goto_inbox('kasia') }
    InboxPage.use do
      inbox.set 'Marzena'
      title = browser.title
    end
    expect(title).to eq 'Mailinator'
  end
end
