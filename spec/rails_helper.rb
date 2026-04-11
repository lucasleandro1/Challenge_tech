require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'

# Disable ActiveRecord fixture setup (app uses Mongoid, not ActiveRecord)
module ActiveRecord
  module TestFixtures
    def setup_fixtures(config = nil); end
    def teardown_fixtures; end
  end
end

RSpec.configure do |config|
  config.use_active_record = false
  config.include FactoryBot::Syntax::Methods
  config.filter_rails_from_backtrace!
end
