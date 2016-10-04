module ActiveForce
  module Relation
    module QueryMethods
      
      def where(conditions)
        #find_by_soql(build_query(conditions: conditions))
        
        querify.build(:where, sanitize_soql_for_assignment(conditions))
      end
      
      def select(*fields)
        querify._select!(*fields)
      end
      
      def _select!(*fields)
        fields.flatten!
        # TODO make this an array rather than a string?
        self.field_list = fields.join(', ')
        
        self
      end
      
      def limit(num_records)
        querify._limit!(num_records)
      end
      
      def _limit!(num_records)
        self.number_of_rows_to_return = num_records
        self
      end
      
      def offset(num_records)
        querify._offset!(num_records)
      end
      
      def _offset!(num_records)
        self.number_of_rows_to_skip = num_records
        self
      end
      
    end
  end
end