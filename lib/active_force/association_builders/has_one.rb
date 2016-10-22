module ActiveForce
  module AssociationBuilders
    class HasOne < SingularAssociation
      
      ADDITIONAL_VALID_OPTIONS = [].freeze
      
      def evaluate
        records = super
        
        raise "Found more than one" if records.respond_to?(:size) && records.size > 1
        
        records
      end
      
      def valid_options
        (super.dup << ADDITIONAL_VALID_OPTIONS).flatten
      end
      
    end
  end
end
