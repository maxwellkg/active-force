module ActiveForce
  module Relation
    module Calculations
      
      def count(column_name = nil)
        calculate(:count, column_name)
      end
      
      def average(column_name)
        calculate(:avg, column_name)
      end
      
      def minimum(column_name)
        calculate(:min, column_name)
      end
      
      def maximum(column_name)
        calculate(:min, column_name)
      end
      
      def sum(column_name = nil, &block)
        calculate(:sum, column_name)
      end
      
      def pluck(*column_names)
        
      end
      
      def ids
        pluck(:id)
      end
      
      def calculate(operation, column_name)
        selector = "#{operation}(#{column_name})"
        
        q = ActiveForce::Query.new(field_list: selector, object_type: self.sobject_name)
        
        result = Client.connection.execute_soql(q.to_soql)
        
        operation == :count ? result['totalSize'] : result['records'].first['expr0']
      end
      
    end
  end
end
