module SalesforceHelper

  module ResponseHelper
    
    def is_good?
      code = self.code.to_i
      code >= 200 && code < 300
    end
    
    def is_bad?
      !is_good?
    end
    
  end
  
  module StringMethods
  
    def rubify
      self.tableize.singularize
    end
  
  end

end