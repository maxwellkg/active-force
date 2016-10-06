module ActiveForce
  module Queries
    module FinderMethods
      
      Hash.send(:include, ActiveForce::Type::HashMethods)
      
      def find(*args)
        return super if block_given?
        find_with_ids(*args)
      end
      
      def find_by(*args)
        where(*args).first
        # TODO, this will load a bunch of records and then choose the first
        # we'll want to do something like .take so that we only get the first record
        # to begin with
      end
      
      
      # Class#all is now deprecated, so we should change this to match newer versions of rails
      def all(conditions: nil)
        find_by_soql(build_query(conditions: conditions))
      end
  
      def find_by_soql(query)
        result = client.execute_soql(query)['records']
        _metamorphose(result)
      end
      
      def find_with_ids(*ids)
        expects_array = ids.first.is_a? Array
        return ids.first if expects_array && ids.first.nil?
        
        ids = ids.flatten.compact.uniq
        
        case ids.size
        when 0
          raise "Record not found. You must specify an ID to locate a record in Salesforce"
        when 1
          result = find_one(ids.first)
          expects_array ? Array(result) : result
        else
          find_some(ids)
        end
      end
      
      def find_one(id)
        _metamorphose(_load(id))
      end
      
      def find_some(ids)
        results = []
        ids.each do |id|
          results.push(find_one(id))
        end
        
        results
      end
      
      def find_nth(index, limit: 1)
        query = querify!
        
        # default ordering in SFDC should be by the created date
        query.field_order_by_list ||= 'CreatedDate ASC'
        query.number_of_rows_to_skip = index
        query.number_of_rows_to_return = limit
        find_by_soql(query.to_soql)
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
      
      def first(limit = nil)
        limit.present? ? find_nth(0, limit) : find_nth(0)
      end
      
      def first!
        find_nth!(0)
      end
      
      def second
        find_nth(1)
      end
      
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
      
      def last!
        find_nth_from_last!(0)
      end
      
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
      
      private
      
        def _load(id)
          Client.connection.get(id, self)        
        end
        
        # creates a new instance (or collection of instances) of the class from an API request response
        def _metamorphose(result)
          # TODO what to return if no results?
          if result.is_a? Hash
            self.new(result.rubify_keys)
          else
            if result.size == 1
              _metamorphose(result.first.rubify_keys)
            else
              result.collect do |record|
                _metamorphose(record.rubify_keys)
              end
            end
          end
        end
      
    end
  end
end
