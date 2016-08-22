module ActiveForce
  class Sobject
    
    # custom for ActiveForce
    include ActiveForce::Concerns::Type
    include ActiveForce::Concerns::Persistence
    include ActiveForce::Concerns::Validations
    
    extend ActiveForce::Concerns::FinderMethods
    extend ActiveForce::Concerns::QueryMethods
    
    include ActiveModel::Validations
    
    #include ActiveModel::Model
    
    #define_model_callbacks :save, :only => :before
    #before_save :fill_defaults

    BASE_DEFAULT_ATTRS = {}.freeze
    DEFAULT_ATTRS = {}.freeze
    
    
    def self.client
      ActiveForce::Client.connection
    end
    
    def initialize(attrs={})
      attrs.symbolize_keys!
      self.model_definition.each do |field|
        # TODO protect against unknown attributes
        # first set the appropriate attr_accessor or attr_reader
        ruby_name = field['name'].rubify
        
        class_eval { field['isCreatable'] ? attr_accessor(ruby_name) : attr_reader(ruby_name) }
        set_validations(field)
        
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
    
  end
end