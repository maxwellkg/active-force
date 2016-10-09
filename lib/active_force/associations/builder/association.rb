module ActiveForce
  module Associations
    module Builder
      class Association
        
        VALID_OPTIONS = [:class_name, :foreign_key].freeze
        
        def self.build(model, name, scope, options)
          assert_valid_keys(options)
          
          
        end
        
        def self.valid_options
          VALID_OPTIONS
        end
        
        def self.validate_options(options)
          options.assert_valid_keys(valid_options)
        end
        
      end
    end
  end
end
