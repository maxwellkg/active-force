module ActiveForce
  module Concerns
    module Validations
      extend ActiveModel::Validations
      
      def set_validations(field)
        type = field['type']
        ruby_name = field['name'].to_sym
        nillable = field['nillable']
        
        class_eval { validates_presence_of ruby_name } if !nillable
        
        if type == 'boolean'
          class_eval { validates_inclusion_of ruby_name, :in => [true, false] }
        elsif ['string', 'textarea'].include? type
          class_eval { validates_length_of ruby_name, :maximum => field['length'] }
        elsif ['int', 'double'].include? type
          class_eval { validates_numericality_of ruby_name, :integer_only => type == 'int' }
        end
        
      end
    end
  end
end
