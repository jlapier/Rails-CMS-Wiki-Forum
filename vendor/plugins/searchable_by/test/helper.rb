require 'test/unit'
require 'rubygems'

# gem install redgreen for colored test output
begin require 'redgreen'; rescue LoadError; end

require 'boot' unless defined?(ActiveRecord)

require 'active_record'

require "../lib/searchable_by"
ActiveRecord::Base.send(:include, Offtheline::SearchableBy)