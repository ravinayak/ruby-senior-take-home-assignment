require 'spec_helper'
require 'rack/test'
require 'sinatra/base'
require 'sinatra/json'
require 'vandelay/rest/patients_patient'

RSpec.describe Vandelay::REST::PatientsPatient do
  include Rack::Test::Methods

  let(:app) do
    Class.new(Sinatra::Base) do
      helpers Sinatra::JSON
      register Vandelay::REST::PatientsPatient
    end
  end

  describe "GET /patients/:id" do
    context "when the patient exists" do
      let(:patient_id) { 789 }
      let(:patient_info) do
        {
          id: patient_id,
          name: 'John Doe',
          age: 35,
          gender: 'Male'
        }
      end
     let(:patient_record) { double('Patient', attributes: patient_info) }
  
      before do
        allow(Vandelay::REST::PatientsPatient.patients_srvc).to receive(:retrieve_one).with(patient_id).and_return(patient_record)
      end
  
      it "returns patient information with status 200" do
        get "/patients/#{patient_id}"
  
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq({
          "id" => patient_id,
          "name" => "John Doe",
          "age" => 35,
          "gender" => "Male"
        })
      end
    end
	
    context "when the patient does not exist" do
      let(:patient_id) { 999 }
  
      before do
        allow(Vandelay::REST::PatientsPatient.patients_srvc).to receive(:retrieve_one).with(patient_id).and_return(nil)
      end
  
      it "returns a 404 error" do
        get "/patients/#{patient_id}"
  
        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to eq({ "error" => "Patient not found" })
      end
    end
  end

  describe "GET /patients/:patient_id/record" do
    context "when the patient exists" do
      let(:patient_id) { 123 }
      let(:patient) { double('Patient', id: patient_id) }
      let(:patient_records) do
        {
          province: 'Ontario',
          allergies: ['Peanuts', 'Penicillin'],
          num_medical_visits: 5
        }
      end

      before do
        allow(Vandelay::REST::PatientsPatient.patients_srvc).to receive(:retrieve_one).with(patient_id).and_return(patient)
        allow(Vandelay::REST::PatientsPatient.patient_records_srvc).to receive(:fetch).with(patient).and_return(patient_records)
      end

      it "returns patient information with status 200" do
        get "/patients/#{patient_id}/record"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq({
          "patient_id" => patient_id,
          "province" => "Ontario",
          "allergies" => ["Peanuts", "Penicillin"],
          "num_medical_visits" => 5
        })
      end
    end

    context "when the patient does not exist" do
      let(:patient_id) { 456 }

      before do
        allow(Vandelay::REST::PatientsPatient.patients_srvc).to receive(:retrieve_one).with(patient_id).and_return(nil)
      end

      it "returns a 404 error" do
        get "/patients/#{patient_id}/record"

        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to eq({ "error" => "Patient not found" })
      end
    end
  end
end
