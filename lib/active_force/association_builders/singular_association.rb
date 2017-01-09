module ActiveForce
  module AssociationBuilders
    class SingularAssociation < Association
      
      def evaluate
        records = super.to_a
        
        raise "Found more than one" if records.respond_to?(:size) && records.size > 1
        
        records.first
      end
      
    end
  end
end
