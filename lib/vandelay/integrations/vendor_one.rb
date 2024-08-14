module Vandelay
  module Integrations
    # Ensure the Base class is required
    #
    require_relative 'base'

    class VendorOne < Base

      # Fetches patient record information
      # @param [Integer] patient_id
      # @return [Hash]
      #
      def fetch_patient_record(patient_id)
        response = make_request(:get, "/patients/#{patient_id}")
        data = JSON.parse(response.body)

        {
          province: data['province'],
          allergies: data['allergies'],
          num_medical_visits: data['recent_medical_visits']
        }
      end

      private

      # Name of vendor
      # @return [String]
      #
      def vendor_name
        'one'
      end
      
      # auth_endpoint is defined in the subclass, since it varies depending upon
      # the vendor
      # @return [String]
      #
      def auth_endpoint
        '/auth/1'
      end
    end
  end
end
