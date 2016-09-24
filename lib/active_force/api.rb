require 'net/http'
# TODO do we really need to require this in each file? probably not. fix later.

module ActiveForce
  module API
    
    module ResponseMethods
      
      def is_good?
        code = self.code.to_i
        code >= 200 && code < 300
      end
  
      def is_bad?
        !is_good?
      end
      
    end
    
  end
end
