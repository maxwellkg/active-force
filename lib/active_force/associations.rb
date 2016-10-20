module ActiveForce
  module Associations
    
    # We'll want to be able to include associations with both objects stored on the SFDC platform
    # as well as those that are handled by Rails
    
    String.send(:include, ActiveForce::Inflector)
   
    def has_one(name, scope = nil, **options)
      
    end
    
    def has_many(name, scope = nil, **options)
      
    end
    
    def belongs_to(name, scope = nil, **options)
      
      klass = options.delete(:class_name)
      options[:foreign_key] ||= :id
      
      ActiveForce::Associations::Builder::HasOne.build(klass, name, scope, options)
    end
    
    def has_and_belongs_to_many(name, scope = nil, **options)
      
    end
    
  end
end