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
      self.send(:define_method, name.to_sym) do
      ActiveForce::AssociationBuilders::HasOne.new(self, name, scope, options).evaluate
      end
    end
    
    def has_and_belongs_to_many(name, scope = nil, **options)
      
    end
    
    module InstanceMethods
    
      def evaluate_chain(chain)
        dup_chain = chain.dup
        ap chain.object_id
        ap dup_chain.object_id
        
        
        dup_chain.each do |link|
          if link.is_a?(Hash)
            link.each do |bind, values|
              if values.is_a?(Hash)
                values.each do |attribute, assignment|
                  if assignment.is_a?(Proc)
                    values[attribute] = instance_eval(&assignment)
                  end
                end
              end
            end
          end
        end
        
        dup_chain
      end
      
    end
      
  end
end