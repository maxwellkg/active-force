module ActiveForce
  module Inflector

    def activeforce_modulize
     "Salesforce::#{self.capitalize}"
    end

    def activeforce_constantize
      self.activeforce_modulize.constantize
    end
    
  end
end