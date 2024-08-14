module Vandelay
  module Integrations
    # Ensure the Base class is required
    require_relative 'base'

    class VendorTwo < Base
      
      # Fetches patient record information
      # @param [Integer] patient_id
      # @return [Hash]
      #
      def fetch_patient_record(patient_id)
        response = make_request(:get, "/records/#{patient_id}")
        data = JSON.parse(response.body)

        {
          province: data['province_code'],
          allergies: data['allergies_list'],
          num_medical_visits: data['medical_visits_recently']
        }
      end

      private

      # Name of vendor
      # @return [String]
      #
      def vendor_name
        'two'
      end

      # auth_endpoint is defined in the subclass, since it varies depending upon
      # the vendor
      # @return [String]
      #
      def auth_endpoint
        '/auth_tokens/1'
      end
    end
  end
end
