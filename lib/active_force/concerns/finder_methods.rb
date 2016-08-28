module ActiveForce
  module Concerns
    module FinderMethods
      
      Hash.send(:include, ActiveForce::Concerns::Type::HashMethods)
      
      def find(*args)
        return super if block_given?
        find_with_ids(*args)
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