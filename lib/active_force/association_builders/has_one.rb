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
        
        attribute = options[:foreign_key] || "#{self.model.to_s.demodulize.downcase}_id"
        attribute_id = owner.id
        
        chain[:where] = chain[:where].merge({attribute.to_sym => attribute_id})
        
        [chain]
      end
      
    end
  end
end
