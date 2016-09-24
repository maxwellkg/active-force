module ActiveForce
  module Relation
    module QueryMethods
      
      include ActiveForce::Relation::SOQL
      
      def where(conditions)
        find_by_soql(build_query(conditions: conditions))
      end
      
      
      private
      
      def fields_for_soql
        self.description['fields'].map { |f| f['name'] }.join(', ')
      end
      
    end
  end
end