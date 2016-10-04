module ActiveForce
  module Associations
    
    String.send(:include, ActiveForce::Inflector)
   
    # has_one :account, :primary_key => :account_id
    def has_one(name, options = {} )
      raise "Please specify a primary key in order to locate the association" if !options.keys.include(:primary_key)
      
      
    end
     
    def has_many
       
    end
     
    def belongs_to
       
    end
     
    def has_and_belongs_to_many
       
    end
    
  end
end