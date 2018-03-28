module ActiveForce
  class Sobject
    
    # custom for ActiveForce
    include ActiveForce::Type
    include ActiveForce::Persistence
    include ActiveForce::Associations::InstanceMethods
    
    extend ActiveForce::Persistence::ClassMethods
    extend ActiveForce::Queries::FinderMethods
    extend ActiveForce::Queries::QueryMethods
    extend ActiveForce::Queries::QueryBuilder
    extend ActiveForce::Queries::Forcification::ClassMethods
    extend ActiveForce::Queries::Calculations
    extend ActiveForce::Queries::Querification
    extend ActiveForce::Queries::SOQL
    extend ActiveForce::Associations
    extend ActiveForce::Validations
    
    include ActiveModel::Validations
    
    #include ActiveModel::Model
    
    #define_model_callbacks :save, :only => :before
    #before_save :fill_defaults

    BASE_DEFAULT_ATTRS = {}.freeze
    DEFAULT_ATTRS = {}.freeze

    class_attribute :sobject_name, :model_definition, :fields
    
    def initialize(attrs={}, definition=nil)
      self.model_definition
      attrs.symbolize_keys!
      
      self.class.model_definition.each do |field|
        # first set the appropriate attr_accessor or attr_reader
        ruby_name = field['name'].rubify
        val = attrs[ruby_name.to_sym] || field['defaultValue']
        instance_variable_set("@#{ruby_name}", type_cast(type: field['type'], value: val))
      end
      
      self
    end

    def self.sobject_name
      @sobject_name ||= self.to_s.demodulize.downcase
    end
    
    def self.model_definition
      return @model_definition if @model_definition.present?

      fields = self.description['fields']
      fields.each do |field|
        ruby_name = field['name'].rubify

        field['updateable'] ? attr_accessor(ruby_name) : attr_reader(ruby_name)
        set_validations(field, self)
      end

      @model_definition = fields
    end

    def self.fields
      fields ||= model_definition.map { |field| field['name'].rubify.to_sym }
    end
    
    def attributes
      attrs = {}
      self.instance_variables.reject { |v| [:@model_definition, :@errors, :@record_type_id].include?(v) }.each { |v| attrs[v.to_s.gsub('@','')] = self.instance_variable_get(v) }
      attrs
    end

    private
    
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
      
      def self.client
        ActiveForce::Client.connection
      end
      
      def self.description
        client.describe(self)
      end
      
      def self.not_createable
        self.description['fields'].collect { |f| f['name'] if f['createable'] == false }
      end
      
      def self.not_updateable
        self.description['fields'].collect { |f| f['name'] if f['updateable'] == false }
      end
    
  end
end