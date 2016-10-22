module ActiveForce
  module AssociationBuilders
    module Builder
      class Association
      
        VALID_OPTIONS = [:class_name, :foreign_key].freeze
        
        def build_association(owner, klass, name, scope, options)
          assert_valid_keys(options)
  
          owner.send(:define_method, name.to_sym) do
            ActiveForce::Associations::Association.new(klass, chain)
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
end
