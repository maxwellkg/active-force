module ActiveForce
  module Associations
    module Builder
      
      VALID_OPTIONS = [:class_name, :foreign_key].freeze
      
      def build_association(model, name, scope = {}, options = {})
        assert_valid_keys(options)
        
        chain = scope.merge(options)

        self.send(:define_method, name.to_sym) do
          ActiveForce::Associations::Association.new(model, chain)
        end
      end
      
      def valid_options
        VALID_OPTIONS
      end
      
      def validate_options(options)
        options.assert_valid_keys(valid_options)
      end
      
    end
  end
end
