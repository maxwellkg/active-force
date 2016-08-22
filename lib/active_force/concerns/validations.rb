module ActiveForce
  module Concerns
    module Validations
      
      def set_validations(field)
        type = field['type']
        ruby_name = field['name'].rubify.to_sym
        
        nillable = field['nillable']
                    
        allow_set = if new_record?
                      field['createable'] && !self.class.not_really_creatable.include?(field['name'])
                    else
                      field['updateable'] && !self.class.not_really_updateable.include?(field['name'])
                    end
        
        class_eval { validates_presence_of ruby_name } if !nillable && allow_set
        
        if type == 'boolean'
          class_eval { validates_inclusion_of ruby_name, :in => [true, false], :allow_nil => (nillable || !allow_set) }
        elsif ['string', 'textarea'].include? type
          class_eval { validates_length_of ruby_name, :maximum => field['length'], :allow_nil => (nillable || !allow_set) }
        elsif ['int', 'double'].include? type
          class_eval { validates_numericality_of ruby_name, :integer_only => type == 'int', :allow_nil => (nillable || !allow_set) }
        end
        
      end
    end
  end
end
