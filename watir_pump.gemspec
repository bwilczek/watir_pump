$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'watir_pump'
  s.version      = '0.0.1'
  s.summary      = 'Page Objects for Watir'
  s.author       = 'Bartek Wilczek'
  s.email        = 'bwilczek@gmail.com'
  s.files        = Dir['lib/**/*.rb']
  s.require_path = 'lib'
  s.homepage     = 'https://github.com/bwilczek/watir_pump'
  s.license      = 'MIT'
  s.required_ruby_version = '~> 2.2'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_dependency 'watir', '~> 6.10'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.52'
end
