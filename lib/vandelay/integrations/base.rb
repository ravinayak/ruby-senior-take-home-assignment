require 'net/http'
require 'json'

module Vandelay
  module Integrations
    class Base
      def initialize
        @base_url = Vandelay.config.dig('integrations', 'vendors', vendor_name, 'api_base_url')
      end

      # Method should be implemented in subclass
      # @param [Integer] patient_id
      #
      def fetch_patient_record(patient_id)
        raise NotImplementedError
      end

      private

      # Method should be implemented in subclass
      #
      def vendor_name
        raise NotImplementedError
      end

      # Fetches authorization token from authentication endpoint and parses response body
      # auth_endpoint is defined as an abstract method at the bottom of this class
      # It should be implemented by subclasses to provide the specific authentication endpoint
      # Response for get request varies for the two vendors, token is returned as 'auth_token'
      # for vendor_two and as 'token' for vendor_one
      #
      def get_auth_token
        response = make_request(:get, auth_endpoint)
        JSON.parse(response.body)['auth_token'] || JSON.parse(response.body)['token']
      end

      # Makes request to the api endpoint to fetch patient records information. This method
      # makes a call to get authorization token when the endpoint is not auth_endpoint. It
      # adds Auth token as a bearer token to Authorization header, and then makes a call
      # to the actual API endpoint to fetch data
      # 1. subclass calls makes_request with actual endpoint to fetch patient records information
      # 2. make_request checks if the endpoint is not auth_endpoint
      # 3. If it is not auth_endpoint, it calls get_auth_token
      # 4. get_auth_token makes request with auth_endpoint
      # 5. An infinite loop is avoided by using conditional check of endpoint == auth_endpoint
      # 6. The auth request is made without Authorization header
      # 7. The token is returned and used for original request
      # @param [Symbol] method
      # @param [String] endpoint
      # @param [Hash] headers
      # @return [Net::HTTP::Response]
      #
      def make_request(method, endpoint, headers = {})
        uri = URI("http://#{@base_url}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        
        request = case method
                  when :get
                    Net::HTTP::Get.new(uri)
                  else
                    raise "Unsupported HTTP method: #{method}"
                  end

        headers.each { |key, value| request[key] = value }

        request['Authorization'] = "Bearer #{get_auth_token}" unless endpoint == auth_endpoint

        http.request(request)
      end

      # Implemented in the subclass
      #
      def auth_endpoint
        raise NotImplementedError
      end
    end
  end
end