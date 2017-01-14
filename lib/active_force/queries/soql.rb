module ActiveForce
  module Queries
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
      
      def sanitize_soql_for_inequality(assignments)
        # keep this way or do something more complicated but in line w/ rails ??
        case assignments
        when Array
          # != or NOT IN will already be specified
          sanitize_soql_array(assignments)
        when Hash
          sanitize_soql_inequal_hash(assignments)
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
        assignments.collect do |k,v|
          if v.is_a? Array
            "#{forcify(k)} IN (#{v.collect { |value| quote_bound_value(value) }.join(',')})"
          else
            "#{forcify(k)}=#{quote_bound_value(v)}"
          end
        end.join(' AND ')
        
      end
      
      def sanitize_soql_inequal_hash(assignments)
        assignments.collect do |k,v|
          if v.is_a? Array
            "#{forcify(k)} NOT IN (#{v.collect { |value| quote_bound_value(value) }.join(',')})"
          else
            "#{forcify(k)} != #{quote_bound_value(v)}"
          end
        end.join(' AND ')
      end
      
      def quote_bound_value(value)
        case value
        when nil
          "NULL"
        when String
          "'#{value}'"
        else
          value
        end
        #value.is_a?(String) ? "'#{value}'" : value
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
