require 'spec_helper'
require 'vandelay/services/patient_records'
require 'vandelay/integrations/vendor_one'
require 'vandelay/integrations/vendor_two'

RSpec.describe Vandelay::Services::PatientRecords do
  let(:cache) { instance_double(Vandelay::Util::Cache) }

  before do
    allow(Vandelay::Util::Cache).to receive(:new).and_return(cache)
  end

  shared_examples 'patient record retrieval' do |vendor, vendor_class|
    let(:patient) { double('Patient', records_vendor: vendor, vendor_id: '123', id: 12) }
    let(:integration) { instance_double(vendor_class) }

    before do
      allow(vendor_class).to receive(:new).and_return(integration)
    end

    it 'fetches patient record from cache if available' do
      cached_record = { province: 'ON', allergies: ['peanuts'], num_medical_visits: 5 }
      allow(cache).to receive(:fetch).and_return(cached_record)

      result = described_class.fetch(patient)
      expect(result).to eq(cached_record)
    end

    it 'fetches patient record from integration if not in cache' do
      integration_record = { province: 'QC', allergies: ['cats'], num_medical_visits: 3 }
      allow(cache).to receive(:fetch).and_yield
      allow(integration).to receive(:fetch_patient_record).and_return(integration_record)

      result = described_class.fetch(patient)
      expect(result).to eq(integration_record)
    end
  end

  describe 'with VendorOne' do
    include_examples 'patient record retrieval', 'one', Vandelay::Integrations::VendorOne
  end

  describe 'with VendorTwo' do
    include_examples 'patient record retrieval', 'two', Vandelay::Integrations::VendorTwo
  end
end