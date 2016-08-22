module ActiveForce
  class Account < Sobject
    
    DEFAULT_ATTRS = {}
    
    def default_values
      super.merge(DEFAULT_ATTRS)
    end
    
    def self.not_really_creatable
      [].push(super).flatten
    end
    
    def self.not_really_updateable
      [].push(super).flatten
    end
   
  end
end