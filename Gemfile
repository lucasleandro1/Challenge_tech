source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "puma", ">= 5.0"
gem "mongoid", "~> 9.0"
gem "devise"
gem "sidekiq"
gem "sidekiq-cron"
gem "httparty"
gem "nokogiri"
gem "bootsnap", require: false
gem "ostruct"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "mongoid-rspec"
  gem "webmock"
end
