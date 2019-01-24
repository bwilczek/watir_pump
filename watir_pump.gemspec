# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name         = 'watir_pump'
  s.version      = '0.4.8'
  s.summary      = 'Page Object pattern for Watir. Hacker friendly and enterprise ready.'
  s.author       = 'Bartek Wilczek'
  s.email        = 'bwilczek@gmail.com'
  s.files        = Dir['README.md', 'lib/**/*.rb']
  s.require_path = 'lib'
  s.homepage     = 'https://github.com/bwilczek/watir_pump'
  s.license      = 'MIT'
  s.required_ruby_version = '~> 2.4'
  s.add_dependency 'activesupport', '>= 4.0.0'
  s.add_dependency 'addressable', '~> 2.5'
  s.add_dependency 'watir', '~> 6.9'
  s.add_development_dependency 'pry', '~> 0.11'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.52'
  s.add_development_dependency 'sinatra', '~> 2.0', '>= 2.0.3'
end
