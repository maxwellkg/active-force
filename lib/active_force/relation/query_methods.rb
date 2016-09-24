module ActiveForce
  module Relation
    module QueryMethods
      
      def where(conditions)
        find_by_soql(build_query(conditions: conditions))
      end
      
    end
  end
end