module ActiveForce
  module Relation
    module Forcification
   
      def forcify(ruby_name)
        klass = self.is_a?(ActiveForce::Query) ? self.object_type.activeforce_modulize.constantize : self.class
        klass.forcify(ruby_name)
      end
   
      module ClassMethods
   
        def forcify(ruby_name)
          description['fields'].detect { |f| f['name'].rubify == ruby_name.to_s }['name']
        end
        
      end
      
      
    end
  end
end