module ActiveForce
  module Relation
    module QueryMethods
      
      def where(conditions)
        #find_by_soql(build_query(conditions: conditions))
        
        querify.build(:where, sanitize_soql_for_assignment(conditions))
      end
      
      def or(other)
        if other.is_a?(ActiveForce::Query)
          querify._or!(other)
        else
          raise "You have passed object of type #{other.class} to #or. Try passing an object of type ActiveForce::Query"
        end
      end
      
      def _or!(other)
        check_valid_or_statement(other)
        
        self.condition_expression << " OR #{other.condition_expression}"
        self
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
      
      private
      
        def check_valid_or_statement(other)
          raise "Both statements must include a matching having or where clause to use or" if !_valid_or_statement?(other)
        end
        
        def _valid_or_statement?(other)
          # both have a where clause or a having clause
    
          [:condition_expression, :having_condition_expression].collect do |expr|
            self.send(expr).present? && other.send(expr).present?
          end.any?
        end
      
    end
  end
end