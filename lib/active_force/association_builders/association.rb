module ActiveForce
  module AssociationBuilders
    class Association
      
      # This is the base object for all associations related to ActiveForce
      # Put simply, each association is made up of three major pieces:
      #
      #   Owner:
      #     # the owner specifies which class owns the relationship
      #   Reflection:
      #     # specifies the class that the owner is calling out to
      #   Chain:
      #     # since the ActiveForce objects may be associated with either SFDC objects
      #     # or rails objects, the association will build a chain of methods that will
      #     # construct the appropriate query
      #     # Construction itself will be handled by ActiveRecord or by ActiveForce,
      #     # depending on the class of the object
      #     # but the chain should work identically as ActiveForce has been modeled after ActiveRecord
      #     # the chain should be an array of Hashes
      
      attr_reader :model, :chain
      
      VALID_OPTIONS = [:class_name, :foreign_key].freeze
      
      def initialize(owner, name, scope = nil, options = {})
        @model = options[:class_name] || name.to_s.camelize.singularize.constantize
        @chain = build_chain(owner, name, scope, options)
        self
      end
      
      def evaluate
        chained = self.model
        @chain.each do |link|
          link.each do |method_name, args|
            chained = chained.send(method_name, args)
          end
        end
        
        chained
      end
      
      def valid_options
        VALID_OPTIONS
      end
      
      def validate_options(options)
        options.assert_valid_keys(valid_options)
      end
      
=begin
      def inspect
        chained = self.model
        @chain.each do |link|
          link.each { |method_name, args| chained = chained.send(method_name, args) }
        end
        
        chained
      end
=end
      
    end
  end
end
