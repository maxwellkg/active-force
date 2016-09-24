module ActiveForce
  module Relation
    module QueryBuilder
      
      def build_query(fields: nil, conditions: nil)
        fields ||= fields_for_soql
        
        query = "SELECT #{fields} FROM #{self.sobject_name} #{"WHERE #{sanitize_soql_for_assignment(conditions)}" if conditions}"
      end
      
      private
      
        def fields_for_soql
          description['fields'].map { |f| f['name'] }.join(', ')
        end
      
      
    end
  end
end
