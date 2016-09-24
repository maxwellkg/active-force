module ActiveForce
  class Opportunity < Sobject
    has_one :account, :primary_key => :account_id
  end
end