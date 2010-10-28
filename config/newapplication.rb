(in /home/jason/dev/projects/Rails-CMS-Wiki-Forum)
# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

module Rails-CMS-Wiki-Forum
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # See Rails::Configuration for more options.
  
    # Skip frameworks you're not going to use. To use Rails without a database
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
    # Specify gems that this application depends on. 
    # They can then be installed with "rake gems:install" on new installations.
    # config.gem "bj"
    # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
    # config.gem "aws-s3", :lib => "aws/s3"
    config.gem "RedCloth"
    config.gem "authlogic"
    config.gem "authlogic-oid", :lib => "authlogic_openid"
    config.gem "ruby-openid", :lib => "openid"
    config.gem "rspec", :lib => false, :version => ">= 1.2.0"
    config.gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
    config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
    config.gem "factory_girl", :source => "http://gemcutter.org", :version => '>= 1.2.4'
  
    # Only load the plugins named here, in the order given. By default, all plugins 
    # in vendor/plugins are loaded in alphabetical order.
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
    # Force all environments to use the same logger level
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug
  
    # Make Time.zone default to the specified zone, and make Active Record store time values
    # in the database in UTC, and return them converted to the specified local zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
    config.time_zone = 'UTC'
  
    # Your secret key for verifying cookie session data integrity.
    # If you change this key, all old sessions will become invalid!
    # Make sure the secret is at least 30 characters and all random, 
    # no regular words or you'll be exposed to dictionary attacks.
    config.action_controller.session = {
      :key => '_site_on_rails_session',
      :secret      => '42b1a00f9cc222749e00675885e0ff4a2de996cd1586e15cfcb7fa34a76a8e8423f8217986b675df3f1c28c056455fc63d6f98eee85c176b377988b5b72ef15d'
    }
  
    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with "rake db:sessions:create")
    #config.action_controller.session_store = :active_record_store
  
    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
  
    # Activate observers that should always be running
    config.active_record.observers = [:wiki_page_observer, :user_observer]
  end
end
