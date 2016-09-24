module ActiveForce
  module Relation
    module Calculations
      
      def count(conditions: nil)
        q = build_query(fields: "COUNT()", conditions: conditions)
        client.execute_soql(q)['totalSize']
      end
      
      def all(conditions: nil)
        q = build_query(conditions: conditions)
        client.execute_soql(q)
      end
      
    end
  end
end
