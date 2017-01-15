require 'test_helper'

class ActiveForce::QueryTest < ActiveForce::BaseTest
  
  test "correct_soql_output" do
    q = ActiveForce::Query.new(field_list: ['id'], object_type: 'Account')
    assert_equal "SELECT id FROM Account", q.to_soql
  end
  
  test "loading_records" do
    q = ActiveForce::Account.select(:id).limit(1)
    assert_equal q.loaded?, false
    
    q.exec_queries
    assert_equal q.loaded?, true
  end
  
end