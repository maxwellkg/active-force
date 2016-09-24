module ActiveForce
  module Relation
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

      def find_by_soql(query)
        _metamorphose(Client.connection.execute_soql(query)['records'])
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
      
      def find_nth_query(order_by:, index:)
        order_by.upcase!
        raise "Not a valid ordering" if !['ASC','DESC'].include?(order_by)

        "SELECT Id FROM #{self.sobject_name} ORDER BY CreatedDate #{order_by} LIMIT 1 OFFSET #{index - 1 }"
                
      end
      
      def find_nth(index)
        query = find_nth_query(order_by: 'ASC', index: index)
        
        id = client.execute_soql(query)['records'].first['Id']
        
        find_one(id)
      end
      
      def find_nth!(index)
        find_nth(index) or raise "Couldn't find #{self.sobject_name} with index #{index}"
      end
      
      def find_nth_from_last(index)
        query = find_nth_query(order_by: 'DESC', index: index)
        
        id = client.execute_soql(query)['records'].first['Id']
        
        find_one(id)
      end
      
      def find_nth_from_last!(index)
        find_nth_from_last(index) or raise "Couldn't find #{self.sobject_name} with index of - #{index}"
      end
      
      def first
        find_nth(1)
      end
      
      def first!
        find_nth!(1)
      end
      
      def second
        find_nth(2)
      end
      
      def second!
        find_nth!(2)
      end
      
      def third
        find_nth(3)
      end
      
      def third!
        find_nth!(3)
      end
      
      def fourth
        find_nth(4)
      end
      
      def fourth!
        find_nth!(4)
      end
      
      def fifth
        find_nth(5)
      end
      
      def fifth!
        find_nth!(5)
      end
      
      def last
        find_nth_from_last(1)
      end
      
      def last!
        find_nth_from_last!(1)
      end
      
      def second_to_last
        find_nth_from_last(2)
      end
      
      def second_to_last!
        find_nth_from_last!(2)
      end
      
      def third_to_last
        find_nth_from_last(3)
      end
      
      def third_to_last!
        find_nth_from_last!(3)
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
            _metamorphose(result.first)
          else
            collection = []
            results.each do |record|
              collection.push(_metamorphose(record))
            end
            collection
          end
        end
      end
      
    end
  end
end