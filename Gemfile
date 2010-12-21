source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'sqlite3-ruby', :require => 'sqlite3'

gem "acts_as_versioned"
gem 'acts_as_revisable', {
  :git => "git://github.com/inertialbit/acts_as_revisable.git",
  :branch => 'rails3'
}
gem 'authlogic', :git => 'http://github.com/binarylogic/authlogic.git'
gem 'authlogic-oid', :require => 'authlogic_openid'
gem 'cancan'
gem 'event_calendar_engine', '~> 0.1.6', :require => 'event_calendar'
gem 'file_share', '~> 0.1.5'
gem 'formtastic'
gem 'RedCloth'
gem 'ruby-openid', :require => 'openid'
gem "will_paginate", "~> 3.0.pre2"

group :development, :test do
  gem 'rspec-rails'
  gem 'webrat'
  gem 'factory_girl'
end

group :production do
  gem 'mysql'
end
