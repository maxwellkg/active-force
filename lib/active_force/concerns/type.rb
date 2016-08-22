module ActiveForce
  module Concerns
    module Type
      
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
      
      module String
        
        def rubify
          self.tableize.singularize
        end
        
        def forcify
          
        end
        
      end
      
      module Symbol
        
        def rubify
          self.to_s.rubify
        end
        
        def forcify
          self.to_s.forcify
        end
        
      end
      
    end
  end
end