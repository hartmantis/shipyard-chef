# Encoding: UTF-8

source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'yard-chef'
  gem 'guard'
  gem 'cane'
  gem 'countloc'
  gem 'rubocop'
  # TODO: Most recent Foodcritic gem has a dep conflict w/ Chef
  gem 'foodcritic', github: 'acrmp/foodcritic'
  # TODO: Guard-foodcritic has a dep conflict w/ Berkshelf 3
  # gem 'guard-foodcritic'
  gem 'rspec'
  gem 'chefspec'
  gem 'guard-rspec'
  gem 'fauxhai'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
  gem 'guard-kitchen'

  # Gems used on the remote Kitchen machine(s) but not locally
  # gem 'cucumber'
  # gem 'serverspec'
end

gem 'chef'
gem 'berkshelf'
