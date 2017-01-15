module ActiveForce
  module Queries
    module QueryMethods
      
      # methods beginning with an underscore should only be called on instances
      # of ActiveForce::Query
      # those without an underscore can either be called on instances of
      # ActiveForce::Query OR as a class method on a child class of 
      # ActiveForce::Sobject
      
      # Note that queries written in comments may use the * notation, which does not actually exist in SOQL
      # For the sake of brevity, * here will stand for the list of fields returned by
      # ActiveForce::Queries::QueryBuilder#fields_for_soql
      
      
      # Returns a new instance of ActiveForce::Query with the given conditions
      #
      #
      # ActiveForce::Account.where(billing_city: "New York")                            # returns all records where the billing city is "New York"
      # ActiveForce::Account.where(billing_city: ["New York", "Mountain View")          # returns all records where the billing city is either New York or Mountain View
      # ActiveForce::Account.where("BillingCity IN ?", ["New York", "Mountain View"])   # see the above example
      #
      # If no conditions are given (as in the case of using #not), will simply return self
      #
      # ActiveForce::Account.where.not(billing_city: "New York")
      
      def where(conditions = nil)
        return self if conditions.nil?
        
        querify!._where!(conditions)
      end
      
      def _where!(conditions)
        self.condition_expression = sanitize_soql_for_assignment(conditions)
        self
      end
      
      # Returns all records where the conditions are NOT the case
      #
      # ActiveForce::Account.where.not(billing_city: "New York")                            # 'SELECT * FROM Account WHERE BillingCity != "New York"'
      # ActiveForce::Account.where.not(billing_city: ['New York', 'Mountain View'])         # 'SELECT * FROM Account where BillingCity NOT IN ('New York', 'Mountain View')'
      # ActiveForce::Account.where.not(billing_city: "New York", name: "SFDC Computing")    # 'SELECT * FROM Account WHERE BillingCity != "New York" AND Name != 'SFDC Computing'"
      
      def not(conditions)
        querify!._not!(conditions)
      end
      
      def _not!(conditions)
        self.condition_expression = sanitize_soql_for_inequality(conditions)
        self
      end
      
      # Returns a new or modified ActiveForce::Query with a modified where clause to include an OR statement
      #
      # You must pass another ActiveForce::Query to this method
      # and the two queries must be structurally compatible, i.e. they have a matching where or having clause
      # and neither include a limit or offset (though these may be added later in the chain)
      #
      # ActiveForce::Account.where(name: 'SFDC Computing').or(ActiveForce::Account.where(name: 'GenePoint'))
      #     # "SELECT * FROM Account WHERE Name = 'SFDC Computing' OR Name = 'GenePoint'"
      
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
      
      # Functions in two ways
      #
      # First, simply defers to Array#select in the case that a block is given
      #     ActiveForce::Account.all.select { |a| a.name == 'SFDC Computing' }
      #
      # Secondly, in the absence of a block, will specify the fields to be selected in the SOQL statement
      #   ActiveForce::Account.select(:id)          # "SELECT Id FROM Account"
      #   ActiveForce::Account.select(:id, :name)   # "SELECT Id, Name FROM Account"
      #   ActiveForce::Account.select([:id, :name]) # "SELECT Id, Name FROM Account"
      
      def select(*fields)
        querify!._select!(fields)
      end
      
      def _select!(*fields)
        fields.flatten!
        self.field_list = fields.map { |f| forcify(f) }
        
        self
      end
      
      # Specifies a limit for the number of records to return
      #
      # ActiveForce::Account.limit(10)                                    # "SELECT * FROM Account LIMIT 10"
      # ActiveForce::Account.where(billing_city: "New York").limit(20)    # 'SELECT * FROM Account WHERE BillingCity = "New York" LIMIT 20'
      
      def limit(num_records)
        querify!._limit!(num_records)
      end
      
      def _limit!(num_records)
        self.number_of_rows_to_return = num_records
        self
      end
      
      # Specifies a number of rows to skip before returning records
      #
      # ActiveForce::Account.offset(10)                                   # 'SELECT * FROM Account OFFSET 10'
      # ActiveForce::Account.where(billing_city: "New York").offset(10)   # 'SELECT * FROM Account WHERE BillingCity = "New York" OFFSET 10'
      
      def offset(num_records)
        querify!._offset!(num_records)
      end
      
      def _offset!(num_records)
        self.number_of_rows_to_skip = num_records
        self
      end
      
      # Specifies an ordering
      #
      # By default, the ordering is done in ASC order, but both DESC and ASC can be explicity given as well
      #
      # ActiveForce::Account.order(:name)                                   # 'SELECT * FROM Account ORDER BY Name ASC'
      # ActiveForce::Account.order(:name => :desc)                          # 'SELECT * FROM Account ORDER BY Name DESC'
      # ActiveForce::Account.order(:billing_city, :year_started => :desc)   # 'SELECT * FROM Account ORDER BY BillingCity ASC, YearStarted DESC'
      # ActiveForce::Account.order('Name DESC')                             # 'SELECT * FROM Account ORDER BY Name DESC'
      
      def order(*args)
        querify!._order!(*args)
      end
      
      def _order!(*args)
        self.field_order_by_list = process_or_arguments(*args)
        self
      end
      
      def includes(*args)
        check_if_method_has_args!(:includes, args)
        querify!._includes!(*args)
      end
      
      def _includes!(*args)

      end
      
      private
      
        def check_if_method_has_args!(method_name, args)
          if args.empty?
            raise ArgumentError "The method .#{method_name} must contain arguments."
          end
        end
      
        def process_or_arguments(*args)
          case args.first
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
            args.first
          end
        end
        
        def process_or_argument_hash(args)
          args.collect { |k,v| "#{forcify(k)} #{v.upcase}" }
        end
      
        def check_valid_or_statement(other)
          raise "Both statements must include a matching having or where clause, and not include a limit or offset, to be structurally valid for #or" if !_valid_or_statement?(other)
        end
        
        def _valid_or_statement?(other)
          # both have a where clause or a having clause
          
          [self, other].each do |query|
            [:number_of_rows_to_return, :number_of_rows_to_skip].each do |attr|
              return false if query.send(attr).present?
            end
          end
    
          [:condition_expression, :having_condition_expression].collect do |expr|
            self.send(expr).present? && other.send(expr).present?
          end.any?
        end
      
    end
  end
end
