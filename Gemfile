source 'http://rubygems.org'

gem 'rake'
gem 'rails', '3.0.10'

gem 'sqlite3-ruby', :require => 'sqlite3'

gem "acts_as_versioned"
gem 'acts_as_revisable', {
  :git => "git://github.com/inertialbit/acts_as_revisable.git"
}
gem 'authlogic'
gem 'authlogic-oid', :require => 'authlogic_openid'
gem 'cancan'
# gem 'event_calendar_engine', '~> 0.2.14', :require => 'event_calendar'

#gem 'file_share', '~> 0.1.14'
#gem 'file_share', :git => 'git://github.com/TACSUO/file_share.git'

gem 'formtastic'
gem 'RedCloth', :require => 'redcloth'
gem 'ruby-openid', :require => 'openid'
gem "will_paginate", "~> 3.0.pre2"

gem 'ri_cal'

group :development, :test do
  gem 'annotate'
  gem 'acts_as_fu'
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'webrat'
  gem 'launchy'
  gem 'database_cleaner'
  # sorry to force mysql in dev/test, had to do some testing
  gem 'mysql2', '~> 0.2.0'
end

group :production do
  gem 'mysql2', '~> 0.2.0'
end

