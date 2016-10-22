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
      options[:foreign_key] ||= "#{name}_id"
      
      chain = scope || Hash.new{ {} }
      
      self.send(:define_method, name.to_sym) do
        chain_to_eval = chain.dup
        # make sure to evaluate the chain
        begin
          attribute_id = options[:foreign_key] ? self.send(options[:foreign_key]) : "#{name}_id"
          chain_to_eval[:where] = chain_to_eval[:where].merge({:id => attribute_id})
        end
                          
        ActiveForce::AssociationBuilders::Association.new(klass, [chain_to_eval]).evaluate
        
        association = ActiveForce::AssociationBuilders::Association.new(klass, [chain_to_eval])
        
        records = association.evaluate
        
        raise "Found more than one result" if records.respond_to?(:size) && records.size > 1
        
        records
      end
      
      #ActiveForce::Associations::Builder::HasOne.build(self, klass, name, chain)
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