require 'bundler/setup'
require 'profitbricks'
require 'support/resource_helper'

Bundler.setup

RSpec.configure do |config|
  config.include Helpers
end

ProfitBricks.configure do |config|
  config.url = 'https://api.profitbricks.com/cloudapi/v4/'
  config.username = ENV['PROFITBRICKS_USERNAME']
  config.password = ENV['PROFITBRICKS_PASSWORD']
  config.debug = false
  config.timeout = 600
  config.interval = 5
end
