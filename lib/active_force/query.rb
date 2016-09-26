module ActiveForce
  class Query
    
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
    }
    
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
      attrs.each do |attr, value|
        instance_variable_set("@#{attr}", value) if self.respond_to?(attr)
      end
    end
    
    def to_soql
      BUILDER.collect do |k,v|
        self.send(v).present? ? "#{k} #{self.send(v)}" : nil
      end.compact.join(' ')
    end
     
  end
end