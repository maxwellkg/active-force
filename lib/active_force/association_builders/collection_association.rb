module ActiveForce
  module AssociationBuilders
    class CollectionAssociation < Association
      
      def evaluate
        super.to_a
      end
      
    end
  end
end
