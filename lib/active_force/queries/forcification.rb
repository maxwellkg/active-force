module ActiveForce
  module Queries
    module Forcification
      
      String.send(:include, ActiveForce::Inflector)
   
      def forcify(ruby_name)
        klass = self.is_a?(ActiveForce::Query) ? self.object_type.activeforce_modulize.constantize : self.class
        klass.forcify(ruby_name)
      end
   
      module ClassMethods
   
        def forcify(obj)
          case obj
          when String
            field = _description['fields'].detect { |f| f['name'].rubify == obj }
            field.nil? ? nil : field['name']
          when Hash
            forcified = {}
            fields = _description['fields']
            obj.each do |k,v|
              field = fields.detect { |f| f['name'].rubify == k }
              forcified[field['name']] = v if field.present?
            end
            forcified.delete(nil)
            forcified
          when Array
            obj.collect { |v| forcify(v) }
          when Symbol
            forcify(obj.to_s)
          else
            raise "Cannot forcify object of type #{obj.class}"
          end
        end
        
      end
      
    end
  end
end
