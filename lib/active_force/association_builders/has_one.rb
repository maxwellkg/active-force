module ActiveForce
  module AssociationBuilders
    class HasOne < SingularAssociation
      
      ADDITIONAL_VALID_OPTIONS = [].freeze
      
      def valid_options
        (super.dup << ADDITIONAL_VALID_OPTIONS).flatten
      end
      
      def build_chain(owner, name, scope, options)
        validate_options(options)
        
        chain = scope || Hash.new { {} }
      end
      
    end
  end
end
