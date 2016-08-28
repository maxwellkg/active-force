module ActiveForce
  module Concerns
    module QueryMethods
      
      def where(conditions)
        Client.connection.execute_soql(conditions)
      end
      
      
      private
      
      def fields_for_soql
        self.description['fields'].map { |f| f['name'] }
      end
      
    end
  end
end