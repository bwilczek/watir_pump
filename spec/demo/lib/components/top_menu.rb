require 'watir_pump'

class TopMenu < WatirPump::Component
  link :index, href: /index/
  link :calculator, href: /calculator/
  link :contact, href: /contact/
end
