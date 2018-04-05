module ActiveForce
  module Queries
    module FinderMethods
      
      Hash.send(:include, ActiveForce::Type::HashMethods)
      
      def self.included(base)
        base.send(:include, ActiveForce::Queries::FinderMethods::TakeMethods)
      end
      
      def self.extended(base)
        base.send(:extend, ActiveForce::Queries::FinderMethods::TakeMethods)
      end
      
      # find by id
      # can take either a single id ("00161000006YCiJAAW"), a list of ids ("00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC"),
      # or an array of ids (["00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC"])
      #
      # ActiveForce::Account.find('00161000006YCiJAAW')                                                 # returns object with id 00161000006YCiJAAW
      # ActiveForce::Account.find("00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC")     # returns an array of objects with ids in ("00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC")
      # ActiveForce::Account.find(["00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC"])   # returns an array of objects with ids in ["00161000006YCiJAAW", "00161000006YCgsAAG", "00161000006X5s3AAC"]
      #
      # note that objects will not be returned in the expected order unless you specify and ordering
      # by using the QueryMethods#order method
      
      def find(*args)
        return super if block_given?
        find_with_ids(*args)
      end
      
      # Will return the first record given the specifications
      # 
      # There is no implied ordering here, so if ordering is important, explicity
      # supply one using QueryMethods#order
      #
      # If no record is found, will return nil
      #
      # ActiveForce::Account.find_by(:id => '00161000006YCiJAAW')
      # ActiveForce::Account.find_by("id = ?", '00161000006YCiJAAW')
      
      def find_by(args)
        where(args).take
        # TODO, this will load a bunch of records and then choose the first
        # we'll want to do something like .take so that we only get the first record
        # to begin with
      end
      
      # identical to #find_by
      # except will raise an error if no record is located
      
      def find_by!(args)
        find_by(args) or raise "Could not locate record for the given specifications: #{args}"
      end

      # Class#all is now deprecated, so we should change this to match newer versions of rails
      def all(conditions: nil)
        find_by_soql(build_query(conditions: conditions).to_soql)
      end
      
      # Will return an array of instances of the class that match the
      # conditions specified in the query
      #
      # Note that the query must be provided as a string, so if using an instance
      # of ActiveForce::Query, make sure to cast the query as a string using #to_soql
      #
      # ActiveForce::Account.find_by_soql('SELECT Id FROM Account LIMIT 1')
      # ActiveForce::Account.find_by_soql(ActiveForce::Query.from_sobject(ActiveForce::Account).to_soql)
      
      def find_by_soql(query)
        result = client.execute_soql(query)['records']
        _metamorphose(result)
      end
      
      # Find the first record (or the first n records if a limit is specified)
      #
      # If no order is supplied, ordering will default to CreatedDate
      #
      # ActiveForce::Account.first      # returns the object returned by executing the query: 'SELECT * FROM Account LIMIT 1 ORDER BY CreatedDate ASC'
      # ActiveForce::Account.first(3)   # returns the 3 objects returned by executing the query: 'SELECT * FROM Account LIMIT 3 ORDER BY CreatedDate ASC'
      # ActiveForce::Account.where(billing_city: "Mountain View").first(3) # returns the first 3 objects found where billing_city is "Mountain View"
      
      def first(limit = nil)
        limit.present? ? find_nth(0, limit: limit) : find_nth(0)
      end
      
      # Nearly identical to #first but will raise an exception if no record is found
      
      def first!
        find_nth!(0)
      end
      
      # Find the second record given the specifications
      #
      # ActiveForce::Account.second     # returns the second object from the query: 'SELECT * FROM Account LIMIT 2'
      # ActiveForce::Account.where(billing_city: "Mountain View").second
      
      def second
        find_nth(1)
      end
      
      # Same as #second, but will raise an exception if no record is found
      
      def second!
        find_nth!(1)
      end
      
      def third
        find_nth(2)
      end
      
      def third!
        find_nth!(2)
      end
      
      def fourth
        find_nth(3)
      end
      
      def fourth!
        find_nth!(3)
      end
      
      def fifth
        find_nth(4)
      end
      
      def fifth!
        find_nth!(4)
      end
      
      # Finds the last record with the given specifications
      #
      # If no order is provided, will order by CreatedDate
      #
      # ActiveForce::Account.last
      # ActiveForce::Account.last(3)
      # ActiveForce::Account.where(billing_city: "Mountain View").last
      
      def last(limit = nil)
        # TODO fix some funniness around this
        if limit.present?
          query = querify!
          
          query.field_order_by_list = 'CreatedDate DESC'
          query.number_of_rows_to_return = limit
        
          find_by_soql(query.to_soql)
        else
          find_nth_from_last(0)
        end
      end
      
      # Same as #last, but will raise an exception if no record is located
      
      def last!
        find_nth_from_last!(0)
      end
      
      # Returns the second to last record with the given specifications
      #
      # ActiveForce::Account.second_to_last
      # ActiveForce::Account.where(billing_city: "New York").second_to_last
      
      def second_to_last
        find_nth_from_last(1)
      end
      
      def second_to_last!
        find_nth_from_last!(1)
      end
      
      def third_to_last
        find_nth_from_last(2)
      end
      
      def third_to_last!
        find_nth_from_last!(2)
      end
      
      def exists?(conditions)
        self.where(conditions).limit(1).any?
      end
      
      module TakeMethods
        
        # the take methods, like query_methods
        # can be used either with a child class of 
        # ActiveForce::Sobject
        # or with an instance of ActiveForce::Query
        
        def take(limit = nil)
          limit ? find_take_with_limit(limit) : find_take
        end
      
        def take!
          take or raise "Couldn't find object of type #{self.sobject_name} with the given specifications"
        end
        
        private
        
          def find_take
            result = self.limit(1)
            
            result.is_a?(Array) ? result.first : result
          end
          
          def find_take_with_limit(limit)
            self.limit(limit)
          end
        
      end
      
      private
      
        def _load(id)
          Client.connection.get_sobject(id, self)
        end
        
        # creates a new instance (or collection of instances) of the class from an API request response
        def _metamorphose(result)
          # TODO what to return if no results?
          if result.is_a? Hash
            self.new(result.rubify_keys)
          else
            result.collect do |record|
              _metamorphose(record.rubify_keys)
            end
          end
        end
        
      def find_one(id)
        _metamorphose(_load(id))
      end
      
      def find_some(ids)
        records = self.where(:id => ids)
        
        if records.size != ids.size
          raise "Could not find records with the following ids: #{ids - records.map(&:id)}"
        else
          records
        end
      end
      
      def find_with_ids(*ids)
        expects_array = ids.first.is_a? Array
        return ids.first if expects_array && ids.first.nil?
        
        ids = ids.flatten.compact.uniq
        
        case ids.size
        when 0
          error_message = "Couldn't find #{self.name} without an ID"
          raise ActiveForce::RecordNotFound.new(error_message, self, primary_key)
        when 1
          begin
            result = find_one(ids.first)
            expects_array ? Array(result) : result
          rescue ActiveForce::ConnectionError => e
            if e.error_code == 'NOT_FOUND'
              msg = "Couldn't find #{self.name} with '#{primary_key}'= #{ids.first}"
              raise ActiveForce::RecordNotFound.new(msg, self, primary_key, ids.first)
            else
              raise e
            end
          end
        else
          find_some(ids)
        end
      end
      
      def find_nth(index, limit: 1)
        expects_array = limit > 1
        query = querify!
        
        # default ordering in SFDC should be by the created date
        query.field_order_by_list ||= 'CreatedDate ASC'
        query.number_of_rows_to_skip = index
        query.number_of_rows_to_return = limit
        
        expects_array ? query.to_a : query.to_a.first
      end
      
      def find_nth!(index)
        find_nth(index) or raise "Couldn't find #{self.sobject_name} with index #{index}"
      end
      
      def find_nth_from_last(index, limit: 1)
        query = querify!
        
        query.field_order_by_list ||= 'CreatedDate DESC'
        
        find_by_soql(query.to_soql)[-index]
      end
      
      def find_nth_from_last!(index)
        find_nth_from_last(index) or raise "Couldn't find #{self.sobject_name} with index of - #{index}"
      end

      # This method is called whenever no results are found for a given id or series of ids, and will raise
      # an ActiveForce::RecordNotFound error.
      #
      # If multiple ids are provided, the error should be raised specifying the number provided +expected size+
      # and the number actually found +result_size+

      def raise_record_not_found_exception!(ids = nil, result_size = nil, expected_size = nil, key = primary_key, not_found_ids = nil)

      end
      
    end
  end
end
