# most of this test setup was pulled from Err's ActsAsTextiled tests
# seems like a nice way to fake AR functionality without hitting a database

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'yaml'
require 'active_support'
require 'action_controller'
require 'test/unit'

class ActiveRecord
  class Base
    attr_reader :attributes
    
    def initialize(attributes = {})
      @attributes = attributes.dup
      after_find if respond_to?(:after_find)
    end

    def method_missing(name, *args)
      if name.to_s[/=/]
        @attributes[key = name.to_s.sub('=','')] = value = args.first
        write_attribute key, value
      else
        self[name.to_s] 
      end
    end

    def save
      true
    end

    def reload
      self
    end

    def [](value)
      @attributes[value.to_s.sub('_before_type_cast', '')]
    end

    def self.global
      eval("$#{name.downcase}")
    end

    def self.find(id)
      item = global.detect { |key, hash| hash['id'] == id }.last
      new(item)
    end
		
		def read_attribute(attr_name)
			attr_name = attr_name.to_s
			if !(value = @attributes[attr_name]).nil?
				if column = column_for_attribute(attr_name)
					if unserializable_attribute?(attr_name, column)
						unserialize_attribute(attr_name)
					else
						column.type_cast(value)
					end
				else
					value
				end
			else
				nil
			end
		end
  end
end 

require File.dirname(__FILE__) + '/../init'

# our would-be faux ActiveRecord model
class SomeModel < ActiveRecord::Base
	acts_as_stripped :name, :description, :number
end
	
# fake model fixture
$somemodel = YAML.load_file(File.dirname(__FILE__) + '/fixtures/some_models.yml')

class ActsAsStrippedTest < Test::Unit::TestCase
  def test_strip_nothing
		some_model = SomeModel.find(1)
		assert_equal some_model.attributes["name"], "normal name"
    assert_equal some_model.name, "normal name"
		assert_equal some_model.attributes["description"], "this one has no textile or html"
		assert_equal some_model.description, "this one has no textile or html"
  end
	
	def test_strips_html
		some_model = SomeModel.find(2)
		assert_equal some_model.attributes["name"], "name with <span style='color:red'>evil</span> html"
		assert_equal some_model.name, "name with evil html"
		assert_equal some_model.attributes["description"], "this one has <strong>unwanted</strong> html"
		assert_equal some_model.description, "this one has unwanted html"
	end
	
	def test_makes_non_string_into_string
		some_model = SomeModel.find(3)
		assert_equal some_model.attributes["number"], 1001
		assert_equal some_model.number, "1001"
	end
end


