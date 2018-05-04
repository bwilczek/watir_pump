# frozen_string_literal: true

require 'watir_pump'
require_relative 'sinatra_helper'

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/(demo|tutorial)/}) do |meta|
    meta[:aggregate_failures] = true
    meta[:watir] = true
  end

  config.before(:suite) do
    Watir.default_timeout = 5
    SinatraHelper.start
    WatirPump.configure do |c|
      c.browser = Watir::Browser.new
      c.base_url = 'http://localhost:4567'
      c.call_page_blocks_with_yield = false
    end
  end

  config.before(:each) do |example|
    WatirPump.config.current_example = example
  end

  config.after(:each, watir: true) do
    WatirPump.config.browser.cookies.clear
    WatirPump.config.browser.goto('about:blank')
  end

  config.after(:suite) do
    SinatraHelper.stop
  end
end
