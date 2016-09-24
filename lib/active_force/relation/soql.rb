module ActiveForce
  module Relation
    module SOQL
      
      def sanitize_soql_for_assignment(assignments)
        case assignments
        when Array
          sanitize_soql_array(assignments)
        when Hash
          sanitize_soql_hash(assignments)
        else
          assignments
        end
      end
      
      def sanitize_soql_array(assignments)
        statement, *values = assignments
        
        if values.first.is_a? Hash
          replace_named_bind_variables(values.first)
        elsif statement.include?("?")
          replace_bind_variables(statement, values)
        else
          statement
        end
      end
      
      def sanitize_soql_hash(assignments)
        assignments.collect { |k,v| "#{k.forcify}=#{quote_bound_value(v)}" }.join(' AND ')
      end
      
      def quote_bound_value(value)
        value.class == String ? "'#{value}'" : value
      end

      def replace_bind_variables(statement, values)
        bound = values.dup
        statement.gsub('?') do
          replacement = case bound.first
                        when Array
                          bound.shift.map { |value| quote_bound_value(value) }.join(',')
                        else
                          quote_bound_value(bound.shift)
                        end
        end
      end
      
      def replace_named_bind_variables(statement, values)
        # TODO
        raise "Not yet implemented."
      end
      
    end
  end
end