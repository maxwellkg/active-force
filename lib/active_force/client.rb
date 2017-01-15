require 'net/http'

module ActiveForce
  class Client
    
    Net::HTTPResponse.send(:include, ActiveForce::API::ResponseMethods)
    
    HOST = 'login.salesforce.com'.freeze
    PORT = 443.freeze
    AUTHENTICATION_ENDPOINT = '/services/oauth2/token'.freeze
    SERVICES_BASE = '/services/data'.freeze
    VERSION = 'v36.0'.freeze
    
    # TODO move this to a secrets file so as not to expose in the
    # code base
    CREDENTIALS = {
      :consumer_key => '3MVG9KI2HHAq33RyB4mAn_ikZ336j8wuOtYbPiz65JEBKekTCfqKzCvazy0xz9u5H1oSMZF3RaHbreTbDsuwp',
      :consumer_secret => '7232983107856014148',
      :username => 'maxwell.gove+sfdc_trailhead@nyu.edu',
      :password => 's@lesforce1!',
      :security_token => 'c43HNPQKnfMbRHLfnXjIpggw'
    }.freeze    
    
    def self.connection
      @connection ||= self.new
    end
    
    def initialize
      authenticate
    end
      
    def get_sobject(id, klass)
      rest_method(:method => :get, :id => id, :klass => klass)
    end
    
    def post_sobject(sobject)
      disinclude = sobject.class.not_createable
      data = sobject.class.forcify(sobject.attributes).reject { |att| disinclude.include?(att) }
      rest_method(:method => :post, :klass => sobject.class, :data => data)
    end
    
    def patch_sobject(sobject)
      disinclude = sobject.class.not_updateable
      data = sobject.class.forcity(sobject.attributes).reject { |att| disinclude.include?(att) }
      rest_method(:method => :patch, :id => sobject.id, :klass => sobject.class, data => data)
    end
    
    def delete_sobject(sobject)
      rest_method(:method => :delete, :id => sobject.id, :klass => sobject.class)
    end
    
    def describe_all
      endpoint_request(:get, "sobjects/")
    end
    
    def describe(klass)
      endpoint_request(:get, "sobjects/#{klass.sobject_name}/describe")
    end
    
    def execute_soql(query)
      
      # TODO see if we need the CGI/if so, find a way around the parentheses issue
      # also need to figure out how to combine the results without flattening
      # which is currently converting the hashes into arrays
      
      #query = CGI.escape(query)
      
      results = endpoint_request(:get, "query/?q=#{query}")
      
      results.push(get_next_records(results)) if results['nextRecordsUrl']
      
      results
      
      #results.flatten
    end
    
    def get_next_records(results)
      id = results['nextRecordsUrl'][results['nextRecordsUrl'].rindex('/')+1..-1]
      
      additional_results = endpoint_request(:get, "query/#{id}")

      additional_results.push(get_next_records(additional_results)) if additional_results['nextRecordsUrl']
    end
    
    
    private
    
      def authenticate
        http = Net::HTTP.new(HOST, PORT)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(AUTHENTICATION_ENDPOINT)
        request.set_form_data({
          :grant_type => 'password',
          :client_id => CREDENTIALS[:consumer_key],
          :client_secret => CREDENTIALS[:consumer_secret],
          :username => CREDENTIALS[:username],
          :password => "#{CREDENTIALS[:password]}#{CREDENTIALS[:security_token]}"
        })
        
        response = http.request(request)
        body_hsh = JSON.parse(response.body)
        
        @instance_host = body_hsh['instance_url'].gsub('https://','')
        @access_token = body_hsh['access_token']
      end
      
      def endpoint_uri(endpoint, params = {})
        URI.encode("#{SERVICES_BASE}/#{VERSION}/#{endpoint}#{"/#{params.map { |k,v| "#{k.to_s}=#{v.to_s}"}}" if !params.empty?}")
      end
        
      def endpoint_request(method, endpoint, data = {})
        ap "beginning request!"
        http = Net::HTTP.new(@instance_host, PORT)
        http.use_ssl = true
        
        request = Net::HTTP.const_get(method.to_s.capitalize).new(endpoint_uri(endpoint, method == :get ? data : {}))
        request['Authorization'] = "Bearer #{@access_token}"
        request['Content-Type'] = 'application/json'
        
        unless data.empty? || method == :get
          ap "deleting id!"
          data.delete('Id')  # the id wil be specified in the request uri, not in the body
          ap data
          request.body = data.to_json
          ap request.body
        end
        
        response = http.request(request)
        
        raise "Salesforce API error #{response.code}: #{response.body} -- #{request.path} #{request.uri} #{request.body}" if response.is_bad?
        
        if response.body
          JSON.parse(response.body)
        else
          {}
        end
        
      end
      
      def rest_method(method:, id: nil, klass:, data:{})
        endpoint_request(method, "sobjects/#{klass.sobject_name}#{"/#{id}" if id.present?}", data)
      end
    
  end
end
