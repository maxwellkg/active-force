module ActiveForce
  module Relation
    module Calculations
      
      def count(conditions: nil)
        q = build_query(fields: "COUNT()", conditions: conditions)
        client.execute_soql(q)['totalSize']
      end
      
    end
  end
end
