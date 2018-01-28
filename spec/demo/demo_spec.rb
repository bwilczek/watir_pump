require_relative 'lib/pages/home_page'

RSpec.describe 'Demo Sinatra App' do
  before(:all) do
    cmd = 'bundle exec ruby sinatra_app/app.rb'
    Process.spawn(cmd, %i[out err] => ['/tmp/watir_pump_sinatra.log', 'w'])
    sleep 1
    WatirPump.config.base_url = 'http://localhost:4567'
  end

  after(:all) do
    pid = File.read('/tmp/watir_pump_sinatra.log').match(/pid=(\d+)/)[1].to_i
    Process.kill 'SIGTERM', pid
  end

  it 'has the right title' do
    HomePage.open do |_page, browser|
      expect(browser.title).to include('Wilhelmine')
    end
  end
end
