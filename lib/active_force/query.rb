module ActiveForce
  class Query
    
    include ActiveForce::Queries::SOQL
    include ActiveForce::Queries::Querification
    include ActiveForce::Queries::QueryMethods
    include ActiveForce::Queries::QueryBuilder
    include ActiveForce::Queries::Forcification
    
    extend ActiveForce::Queries::Forcification::ClassMethods
    
    # see https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select.htm
    # for more information on SOQL SELECT syntax
    
    BUILDER = {
      "SELECT" => :field_list,
      "FROM" => :object_type,
      "WHERE" => :condition_expression,
      "GROUP BY" => :field_group_by_list,
      "ORDER BY" => :field_order_by_list,
      "LIMIT" => :number_of_rows_to_return,
      "OFFSET" => :number_of_rows_to_skip
    }.freeze
    
    attr_accessor(
      :field_list,
      :type_of_field,
      :when_expression,
      :else_expression,
      :object_type,
      :filter_scope,
      :condition_expression,
      :filtering_expression,
      :field_group_by_list,
      :field_subtotal_group_by_list,
      :having_condition_expression,
      :field_order_by_list,
      :number_of_rows_to_return,
      :number_of_rows_to_skip
    )
    
    def initialize(attrs = {})
      attrs.each { |attr, value| self.send("#{attr}=", value) }
      @klass = self.object_type.activeforce_modulize.constantize
      @loaded = false
      
      self
    end
    
    def to_soql
      BUILDER.collect do |k,v|
        self.send(v).present? ? "#{k} #{self.send(v)}" : nil
      end.compact.join(' ')
    end

    def inspect
      entries = self.to_a
      
      if entries.respond_to?(:map)
        entries.map!(&:inspect)
        if entries.size > 10
          entries = entries[1..9]
          entries[10] = '...'
        end

        "#<#{self.class.name} [#{entries.join(', ')}]>"
      else
        entries.inspect
      end
    end
    
    def load
      exec_queries unless loaded?
      
      self
    end
    
    def loaded?
      @loaded == true
    end
    
    def exec_queries
      @records = @klass.find_by_soql(self.to_soql)
      @loaded = true
      @records
    end
    
    def to_a
      self.load
      @records
    end
    
    def self.from_sobject(sobject)
      # TODO we'll need to be able to set fields and potentially other options here
      self.new(field_list: sobject.fields_for_soql, object_type: sobject.sobject_name)
    end
    
    private
    
      def sobject_name
        # TODO we'll need to somehow allow for custom ruby names
        self.object_type.activeforce_modulize
      end
      
      def method_missing(method, *args, &block)
        to_a.send(method, *args, &block)
      end
     
  end
end