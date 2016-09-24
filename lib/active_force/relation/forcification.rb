module ActiveForce
  module Relation
    module Forcification
   
      def forcify(ruby_name)
        description['fields'].detect { |f| f['name'].rubify == ruby_name.to_s }['name']
      end
      
    end
  end
end