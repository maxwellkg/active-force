module ActiveForce
  module Persistence
    
    #include ActiveModel::AttributeAssignment
    include ActiveForce::AttributeAssignment
    include ActiveForce::Validations
    
    def new_record?
      self.id.nil?
    end
    
    def save!
      if valid?
        self.new_record? ? Client.post(self) : Client.patch(self)
        return true
      else
        raise "#{self.errors.full_messages}"
      end
    end
    
    def save
      begin
        save!
      rescue
        false
      end
    end
    
    def update_attribute(name, val)
      assign_attributes({name => val})
      save
    end
    
    def update!(attributes)
      assign_attributes(attributes)
      save!
    end
    alias_method :update_attributes!, :update!
    
    def update
      begin
        update
      rescue
        false
      end
    end
    alias_method :update_attributes, :update
    
    def delete
      Client.connection.delete(self)
    end
    # for the time being, these should be the same
    alias_method :destroy, :delete
    
    module ClassMethods
      
      def create(attributes = nil, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, &block) }
        else
          object = new(attributes, &block)
          object.save
          object
        end
      end
      
      def create!
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, &block) }
        else
          object = new(attributes, &block)
          object.save!
          object
        end
      end
      
    end
    
  end
end
