module ActiveForce
  module AssociationBuilders
    class BelongsTo < SingularAssociation
      
      ADDITIONAL_VALID_OPTIONS = [].freeze
      
      def valid_options
        (super.dup << ADDITIONAL_VALID_OPTIONS).flatten
      end
      
      def build_chain(owner, name, scope, options)
        validate_options(options)
        
        chain = scope || Hash.new { {} }
        
        attribute = options[:foreign_key] || "#{name}_id"
        attribute_id = owner.send(attribute)
        
        chain[:where] = chain[:where].merge({:id => attribute_id})
        
        [chain]
      end
      
    end
  end
end
