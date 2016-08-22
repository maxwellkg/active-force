module ActiveForce
  class Sobject
    
    # custom for ActiveForce
    String.send(:include, ActiveForce::Concerns::Type::String)
    Symbol.send(:include, ActiveForce::Concerns::Type::Symbol)
    include ActiveForce::Concerns::Type
    
    # other
    
    include ActiveModel::Model
    
    define_model_callbacks :save, :only => :before
    before_save :fill_defaults
    
    DEFAULT_ATTRS = {}
    
    
    def self.client
      ActiveForce::Client.connection
    end
    
    def initialize(attrs={})
      attrs.symbolize_keys!
      self.model_definition.each do |field|
        # first set the appropriate attr_accessor or attr_reader
        ruby_name = field['name'].rubify
        
        class_eval { field['isCreatable'] ? attr_accessor(ruby_name) : attr_reader(ruby_name) }
        
        val = attrs[ruby_name.to_sym]
        instance_variable_set("@#{ruby_name}", type_cast(type: field['type'], value: val))
      end
      
      self
    end
    
    def model_definition
      @model_definition ||= self.class.description['fields']
    end
    
    def fill_defaults
      defaults = {}
      model_definition.map do |f|
        defaults[f['name'].to_sym] = f['defaultValue'] if f['defaultValue']
      end
      
      defaults.merge(DEFAULT_ATTRS).each do |k,v|
        if self.send(k).nil?
          self.send("#{k}=", v)
        end
      end
      
      self
    end
    
    def self.find(id)
      self._metamorphose(self._load(id))
    end
    
    def self.sobject_name
      self.to_s.gsub('ActiveForce::','')
    end
    
    def self.description
      client.describe(self)
    end
    
    def self.not_really_creatable
      []
    end
    
    def self.not_really_updateable
      []
    end
    
    private
    
    def self._load(id)
      client.get(id, self)
    end
    
    # creates an instance of the class from an API result
    def self._metamorphose(result)
      rubified_attrs = {}
      result.each do |k,v|
        rubified_attrs[k.rubify] = v
      end
      self.new(rubified_attrs)      
    end
    
  end
end