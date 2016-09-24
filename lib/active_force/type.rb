module ActiveForce
  module Type
    
    def self.included(base)
      String.send(:include, self::StringMethods)
      Symbol.send(:include, self::SymbolMethods)
      Hash.send(:include, self::HashMethods)
    end
    
    def type_cast(type:, value:)
    
      case type
      when 'boolean'
        # value to boolean
        ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
      when 'picklist'
        # value to array
        value&.split(';')
      when 'int'
        value&.to_i
      when 'datetime'
        value&.to_datetime
      when 'date'
        value&.to_date
      else
        # value as given string
        value
      end
    end
    
    module StringMethods
      
      def rubify
        self.tableize.singularize
      end
      
      def forcify(model_definition)
        model_definition.detect { |f| f['ruby_name'] == self }['Name']
      end
      
    end
    
    module SymbolMethods
      
      def rubify
        self.to_s.rubify
      end
      
      def forcify
        self.to_s.forcify
      end
      
    end
    
    module HashMethods
      
      def rubify_keys
        rubified = {}
        self.each { |k,v| rubified[k.rubify] = v }
        rubified
      end
      
    end
    
  end
end