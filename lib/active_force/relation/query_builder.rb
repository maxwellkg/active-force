module ActiveForce
  module Relation
    module QueryBuilder
      
      def build_query(fields: nil, conditions: nil)
        fields ||= fields_for_soql
        
        query = "SELECT #{fields} FROM #{self.sobject_name} #{"WHERE #{sanitize_soql_for_assignment(conditions)}" if conditions}"
      end
      
      
    end
  end
end
