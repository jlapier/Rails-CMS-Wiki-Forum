# NOTE: This test has to be run from the same directory this file (searchable_by_test.rb) is in.

require "helper"
require 'lib/activerecord_test_case'

require '../lib/searchable_by'

class SearchableByTest < ActiveRecordTestCase
  fixtures :companies, :employees

  def test_new_methods_presence
    assert Employee.respond_to?('search')
    assert Employee.respond_to?('search_tables_and_columns')
    assert_equal( { :employees => [:first_name, :last_name, :occupation], :company => [:name, :abbrev] },
      Employee.search_tables_and_columns)
  end

  def test_basic_search
    results_for_one = Employee.search "Bender"
    assert_equal 1, results_for_one.size
    assert_equal "Bender", results_for_one.first.first_name
    results_for_none = Employee.search "Flexo"
    assert_equal 0, results_for_none.size
    results_for_one_company = Company.search "Mom"
    assert_equal 1, results_for_one_company.size
  end

  def test_associative_search
    results_for_three = Employee.search "Planet Express"
    assert_equal 3, results_for_three.size
    assert results_for_three.map(&:first_name).include?("Bender")
    assert !results_for_three.map(&:first_name).include?("Walt")
    results_for_one = Employee.search "MomCorp"
    assert_equal 1, results_for_one.size
    assert_equal "Walt", results_for_one.first.first_name
  end

  def test_quoted_search
    results_for_one = Employee.search '"Delivery Boy"'
    assert_equal 1, results_for_one.size
    assert_equal "Philip", results_for_one.first.first_name
    results_for_none = Employee.search '"Boy Delivery"'
    assert_equal 0, results_for_none.size
  end

  def test_no_require_all_search
    results_for_none = Employee.search 'Delivery Unit'
    assert_equal 0, results_for_none.size
    results_for_two = Employee.search 'Delivery Unit', :require_all => false
    assert_equal 2, results_for_two.size
    assert results_for_two.map(&:first_name).include?("Bender")
    assert results_for_two.map(&:first_name).include?("Philip")
  end

  def test_specify_field_search
    results_for_one = Employee.search 'Delivery', :narrow_fields => :occupation
    assert_equal 1, results_for_one.size
    assert_equal 'Philip', results_for_one.first.first_name
    results_for_none = Employee.search 'Philip', :narrow_fields => :occupation
    assert_equal 0, results_for_none.size
    results_for_three = Employee.search 'Planet', :narrow_fields => { :company => :name }
    assert_equal 3, results_for_three.size
    assert results_for_three.map(&:first_name).include?("Bender")
    assert !results_for_three.map(&:first_name).include?("Walt")
  end

  def test_use_normal_find_options
    results_for_three = Employee.search 'PlanEx', :order => "last_name DESC"
    assert_equal 3, results_for_three.size
    assert_equal ['Rodriguez', 'Leela', 'Fry'], results_for_three.map(&:last_name)
  end

end
