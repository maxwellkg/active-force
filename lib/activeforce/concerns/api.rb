require 'net/http'
# TODO do we really need to require this in each file? probably not. fix later.

module ActiveForce
  module Concerns
    module API
      
      def endpoint_uri(endpoint, params = {})
        URI.encode("#{SERVICES_BASE}/#{VERSION}/")
      end
      
      def endpoint_request(endpoint, method, data = {})
        http = Net::HTTP.new(@instance_host, PORT)
        http.use_ssl = true
        
        request = Net::HTTP.const_get(method.to_s.capitalize).new(endpoint_uri(endpoint, method == :get ? data : {}))
        request['Authorization'] = "Bearer #{@access_token}"
        request['Content-Type'] = 'application/json'
        
        unless data.empty? || method == :get
          data.delete('Id') if data['Id']  # the id wil be specified in the request uri, not in the body
          request.body = data.to_json
        end
        
        response = http.request(request)
        
        raise "Salesforce API error #{response.code}: #{response.body} -- #{request.path} #{request.uri} #{request.body}" if response.is_bad?
        
        if response.body
          JSON.parse(body)
        else
          {}
        end
        
      end
          
      
      
    end
  end
end
