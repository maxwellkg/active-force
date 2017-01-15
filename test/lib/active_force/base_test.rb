require 'test_helper'

class ActiveForce::BaseTest < ActiveSupport::TestCase
  
  test "save_fails" do
    acct = ActiveForce::Account.new
    assert_raise RuntimeError do
      acct.save!
    end
  end
  
  test "creates_a_record" do
    a1 = ActiveForce::Account.last
    assert_nothing_raised do
      a2 = ActiveForce::Account.create({name: "Testing", owner_id: a1.owner_id})
    end
    
  end
  
  test "finds_a_record" do
    a1 = ActiveForce::Account.last

    a2 = ActiveForce::Account.find(a1.id)

    assert_not_equal a2, nil
    
  end
  
end