module SinatraHelper
  LOG_PATH = '/tmp/watir_pump_sinatra.log'

  class << self
    def start
      cmd = 'bundle exec ruby sinatra_app/app.rb'
      Process.spawn(cmd, %i[out err] => [LOG_PATH, 'w'])
      sleep 1
    end

    def stop
      pid = File.read(LOG_PATH).match(/pid=(\d+)/)[1].to_i
      Process.kill 'SIGTERM', pid
    end
  end
end
