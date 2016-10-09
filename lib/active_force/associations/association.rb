module ActiveForce
  module Associations
    class Association
      
      # This is the base object for all associations related to ActiveForce
      # Put simply, each association is made up of three major pieces:
      #
      #   Owner:
      #     # the owner specifies which class owns the relationship
      #   Reflection:
      #     # specifies the class that the owner is calling out to
      #   Chain:
      #     # since the ActiveForce objects may be associated with either SFDC objects
      #     # or rails objects, the association will build a chain of methods that will
      #     # construct the appropriate query
      #     # Construction itself will be handled by ActiveRecord or by ActiveForce,
      #     # depending on the class of the object
      #     # but the chain should work identically as ActiveForce has been modeled after ActiveRecord
      #     # the chain should be an array of Hashes
      
      
      attr_reader :owner, :target, :reflection
      
      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        @chain = []
        self
      end
      
      def inspect
        chained = self
        @chain.each do |method|
          method.each do |method_name, args|
            chained = chained.send(method_name, args)
          end
        end
        
        chained
      end
      
      
      
    end
  end
end
