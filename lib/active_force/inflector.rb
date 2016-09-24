module ActiveForce
  module Inflector
   
   def activeforce_modulize
     "ActiveForce::#{self.capitalize}"
   end
    
  end
end