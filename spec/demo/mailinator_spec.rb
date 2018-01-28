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
  uri '/v2/inbox.jsp?zone=public&query={inbox}'
  text_field :inbox, id: 'inbox_field'
end

WatirPump.configure do |c|
  c.browser = Watir::Browser.new
  c.base_url = 'https://www.mailinator.com'
end

RSpec.describe 'Mailinator' do
  it 'navigates to inbox' do
    HomePage.open { |page| page.goto_inbox('kasia') }
    InboxPage.use do |page, browser|
      page.inbox.set 'Marzena'
      expect(browser.title).to eq 'Mailinator'
    end
  end

  it 'opens inbox directly from URL' do
    InboxPage.open(inbox: 'kasia') do |page, browser|
      page.inbox.set 'Natalia'
      expect(browser.title).to eq 'Mailinator'
    end
  end
end
