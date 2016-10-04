module ActiveForce
  module Relation
    module Querification
   
      def querify
        if self.is_a?(Class) && self.superclass == ActiveForce::Sobject
          ActiveForce::Query.from_sobject(self)
        elsif self.is_a? ActiveForce::Query
          self
        else
          raise "Object of type #{self.class} cannot be querified"
        end
      end
      
    end
  end
end