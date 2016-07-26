module SalesforceHelper

  module ResponseHelper
    
    def is_good?
      response_code = self.code.to_i
      reponse_code >= 200 && response_code < 300
    end
    
    def is_bad?
      !is_good?
    end
    
  end

end