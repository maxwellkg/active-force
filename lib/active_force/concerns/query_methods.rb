module ActiveForce
  module Concerns
    module QueryMethods
      
      def where(conditions)
        Client.connection.execute_soql(build_query(conditions: conditions))
      end
      
      
      private
      
      def fields_for_soql
        self.description['fields'].map { |f| f['name'] }
      end
      
    end
  end
end