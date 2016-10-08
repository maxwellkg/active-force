module ActiveForce
  module Queries
    module QueryMethods
      
      # methods beginning with an underscore should only be called on instances
      # of ActiveForce::Query
      # those without an underscore can either be called on instances of
      # ActiveForce::Query OR as a class method on a child class of 
      # ActiveForce::Sobject
      
      def where(conditions = nil)
        #find_by_soql(build_query(conditions: conditions))
        
        return self if conditions.nil?
        
        querify!._where!(conditions)
      end
      
      def _where!(conditions)
        self.condition_expression = sanitize_soql_for_assignment(conditions)
        self
      end
      
      def not(conditions)
        querify!._not!(conditions)
      end
      
      def _not!(conditions)
        self.condition_expression = sanitize_soql_for_inequality(conditions)
        self
      end
      
      def or(other)
        if other.is_a?(ActiveForce::Query)
          self._or!(other)
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
        querify!._select!(*fields)
      end
      
      def _select!(*fields)
        fields.flatten!
        # TODO make this an array rather than a string?
        self.field_list = fields.map { |f| forcify(f) }.join(', ')
        
        self
      end
      
      def limit(num_records)
        querify!._limit!(num_records)
      end
      
      def _limit!(num_records)
        self.number_of_rows_to_return = num_records
        self
      end
      
      def offset(num_records)
        querify!._offset!(num_records)
      end
      
      def _offset!(num_records)
        self.number_of_rows_to_skip = num_records
        self
      end
      
      def order(*args)
        querify!._order!(*args)
      end
      
      def _order!(*args)
        self.field_order_by_list = process_or_arguments(*args)
        self
      end
      
      private
      
        def process_or_arguments(*args)
          case args
          when Array
            args.collect do |arg|
              if arg.is_a? Hash
                process_or_argument_hash(arg)
              else
                "#{forcify(arg)} ASC"
              end
            end.join(', ')
          when Hash
            process_or_argument_hash(*args)
          else
            args
          end
        end
        
        def process_or_argument_hash(args)
          args.collect { |k,v| "#{forcify(k)} #{v}" }
        end
      
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
