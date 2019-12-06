# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

#DECIDIM_VERSION = "0.17.0"
DECIDIM_VERSION = {github: "Platoniq/decidim", branch: "0.18-live"}
# DECIDIM_VERSION = {path: "../decidim"}
gem "decidim", DECIDIM_VERSION
gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-direct_verifications", github: 'Platoniq/decidim-verifications-direct_verifications'

gem "bootsnap", "~> 1.3"

gem "puma", "~> 3.12"
gem "uglifier", "~> 4.1"

gem "sprockets", "~> 3.7.2"
gem "faker", "~> 1.9"
gem "health_check"
gem "sidekiq"
gem "sidekiq-cron"
gem "sentry-raven"


group :development, :test do
  gem "byebug", "~> 10.0", platform: :mri
  gem 'dotenv-rails'

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production do
  gem "fog-aws"
end
