require 'net/http'

module ActiveForce
  module Concerns
    module Connection
      
      Net::HTTPResponse.send(:include, SalesforceHelper::ResponseMethods)
      
      HOST = 'login.salesforce.com'.freeze
      PORT = 443.freeze
      AUTHENTICATION_ENDPOINT = 'services/oauth2/token'.freeze
      SERVICES_BASE = '/services/data'.freeze
      VERSION = 36.0.freeze
      
      # TODO move this to a secrets file so as not to expose in the
      # code base
      CREDENTIALS = {
        :consumer_key => '3MVG9KI2HHAq33RyB4mAn_ikZ336j8wuOtYbPiz65JEBKekTCfqKzCvazy0xz9u5H1oSMZF3RaHbreTbDsuwp',
        :consumer_secret => '7232983107856014148',
        :username => 'maxwell.gove+sfdc_sandbox@nyu.edu',
        :password => 's@l3sf0rce!',
        :security_token => '0nuspiMGqpLekRK1hFLaJoTn'
      }.freeze    
      
      def connection
        @connection ||= self.new
      end
      
      def initialize
        authenticate
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
          :password => CREDENTIALS[:password]
        })
        
        response = http.request(request)
        body_hsh = JSON.parse(response.body)
        
        @instance_host = body_hsh['server_url']
        @access_token = body_hsh['access_token']
      end
      
    end
  end
end
