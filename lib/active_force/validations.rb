module ActiveForce
  module Validations
    def set_validations(field, klass)
      type = field['type']
      ruby_name = field['name'].rubify.to_sym
      
      nillable = field['nillable']

      klass.send(:define_method, "allow_#{field}_set") do
        new_record? ? field['creatable'] : field['updateable']    
      end

      if !nillable && type != 'boolean'
        klass.send(:define_method, "has_valid_#{field}") do
          self.validates_presence_of ruby_name if self.send("allow_#{field}_set")
        end
      end
      
      #if type == 'boolean'
      #  validates_inclusion_of ruby_name, :in => [true, false], :allow_nil => (nillable || !allow_set)
      #elsif ['string', 'textarea'].include? type
      #  validates_length_of ruby_name, :maximum => field['length'], :allow_nil => (nillable || !allow_set)
      #elsif ['int', 'double'].include? type
      #  class_eval { validates_numericality_of ruby_name, :integer_only => type == 'int', :allow_nil => (nillable || !allow_set) }
      #end
      
    end
      
    def validate!
      self.valid? ? true : self.errors.full_messages
    end
    
  end
end
