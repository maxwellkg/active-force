module ActiveForce
  module Relation
    module QueryBuilder
      
      METHODS = {
        :where => :condition_expression
      }
      
      def build_query(fields: nil, conditions: nil)
        fields ||= fields_for_soql
        
        query = ActiveForce::Query.new(field_list: fields, object_type: self.sobject_name)
      end
      
      def build(method, opts)
        att = METHODS[method] || method
        self.send("#{att}=", opts)
        
        self
      end
    
      def fields_for_soql
        description['fields'].map { |f| f['name'] }.join(', ')
      end
      
      def execute
        Client.connection.execute_soql(self)
      end
      
    end
  end
end
