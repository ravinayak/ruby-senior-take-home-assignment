require 'vandelay/util/cache'
require 'vandelay/integrations/vendor_one'
require 'vandelay/integrations/vendor_two'

module Vandelay
  module Services
    class PatientRecords
      def initialize
        @cache = Vandelay::Util::Cache.new
      end

      # Fetches patient record information
      # @param [Patient] patient
      # @return [Hash]
      #
      def self.fetch(patient)
        new.retrieve_record_for_patient(patient)
      end

      # Retrieves record for patient from cache or by making an API call to
      # external vendor
      # @param [Patient] patient
      # @return [Hash]
      #
      def retrieve_record_for_patient(patient)
        return {} unless patient.records_vendor && patient.vendor_id

        cache_key = "patient_record:#{patient.id}:#{patient.records_vendor}:#{patient.vendor_id}"
        
        @cache.fetch(cache_key, expires_in: 600) do
          integration = get_integration(patient.records_vendor)
          records = integration.fetch_patient_record(patient.vendor_id)

          {
            province: records[:province],
            allergies: records[:allergies],
            num_medical_visits: records[:num_medical_visits]
          }
        end
      end

      private

      # Get integration class for specific vendor defined as a subclass
      # @param [String] vendor
      # @return [Vandelay::Integrations::VendorOne | Vandelay::Integrations::VendorTwo]
      #
      def get_integration(vendor)
        case vendor
        when 'one'
          Vandelay::Integrations::VendorOne.new
        when 'two'
          Vandelay::Integrations::VendorTwo.new
        else
          raise "Unknown vendor: #{vendor}"
        end
      end
    end
  end
end