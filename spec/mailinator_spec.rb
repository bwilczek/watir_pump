require 'watir_pump'

module Mailinator
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
end

RSpec.describe 'Mailinator' do
  before(:all) { WatirPump.config.base_url = 'https://www.mailinator.com' }

  it 'navigates to inbox' do
    Mailinator::HomePage.open { |page| page.goto_inbox('kasia') }
    Mailinator::InboxPage.act do |page, browser|
      page.inbox.set 'Marzena'
      expect(browser.title).to eq 'Mailinator'
    end
  end

  it 'opens inbox directly from URL' do
    Mailinator::InboxPage.open(inbox: 'kasia') do |page, browser|
      page.inbox.set 'Natalia'
      expect(browser.title).to eq 'Mailinator'
    end
  end
end
