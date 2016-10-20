module ActiveForce
  class Opportunity < Sobject
    belongs_to :account, :class_name => ActiveForce::Account
  end
end