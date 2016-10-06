module ActiveForce
  class FinderMethodTest < Test::Unit::TestCase
    
    TEST_ID = '00161000003Er6TAAS'.freeze
    
    TEST_IDS = Set.new(["00161000003Er6TAAS", "00161000003Er6UAAS", "00161000003Er6VAAS"]).freeze
    
    def test_find
      acct = ActiveForce::Account.find(TEST_ID)
      
      # should return an instance of the correct class
      acct.is_a? ActiveForce::Account
      
      # whose id matches the specified id
      acct.id == TEST_ID
    end
    
    def test_find_by_soql
      query = ActiveForce::Query.from_sobject(ActiveForce::Account)
      query.condition_expression = "Id IN (#{TEST_IDS.to_a.collect { |id| "'#{id}'" }.join(', ')})"
      
      accts = ActiveForce::Account.find_by_soql(query.to_soql)
      
      # check type
      accts.is_a? Array
      Set.new(accts.map(&:id)).eql?(TEST_IDS)
    end
    
    def test_find_all
      
    end
    
  end
end
