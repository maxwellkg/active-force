module ActiveForce
  class Sobject
    
    String.send(:include, ActiveForce::Concerns::Type::String)
    include ActiveForce::Concerns::Type
    include ActiveForce::Concerns::Validations
    
    extend ActiveModel::Callbacks
    
    define_model_callbacks :save, :only => :before
    before_save :fill_defaults
    
    DEFAULT_ATTRS = {}
    
    
    def self.client
      ActiveForce::Client.connection
    end
    
    def initialize(attrs={})
      self.model_definition.each do |field|
        # first set the appropriate attr_accessor or # attr_reader
        ruby_name = field['name'].rubify
        
        class_eval { field['isCreatable'] ? attr_accessor(ruby_name) : attr_reader(ruby_name) }
        
        val = attrs[ruby_name]
        instance_variable_set("@#{ruby_name}", type_cast(type: field['type'], value: val))

      end
      
      self
    end
    
    def model_definition
      @model_definition ||= self.class.description['fields']
    end
    
    def save!
      if valid?
        self.new_record? ? Client.post(self) : Client.patch(self)
        self.reload!
        return true
      else
        raise "#{self.errors.full_messages}"
      end
    end
    alias_method :save, :save!
    
    def update!
      
    end
    alias_method :update_attributes!, :update!
      
    
    def fill_defaults
      defaults = {}
      model_definition.map do |f|
        defaults[f['name']] = f['defaultValue'] if f['defaultValue']
      end
      
      defaults.merge(DEFAULT_ATTRS).each do |k,v|
        if self.send(k).nil?
          self.send("#{k}=", v)
        end
      end
      
      self
    end
    
    def self.find(id)
      Client.connection.get(id, self)
    end
    
    def self.sobject_name
      self.to_s.gsub('ActiveForce::','')
    end
    
    def self.description
      Client.connection.describe(self)
    end
    
    def self.not_really_creatable
      []
    end
    
    def self.not_really_updateable
      []
    end
    
    
    
  end
end