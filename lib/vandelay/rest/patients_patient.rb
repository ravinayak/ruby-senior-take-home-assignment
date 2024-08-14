require 'vandelay/services/patients'
require 'vandelay/services/patient_records'
require 'sinatra/base'
require 'sinatra/json'

module Vandelay
  module REST
    module PatientsPatient
      # Initializes Patients class
      #
      def self.patients_srvc
        @patients_srvc ||= Vandelay::Services::Patients.new
      end

      # Initializes PatientRecords class
      #
      def self.patient_records_srvc
        @patient_records_srvc ||= Vandelay::Services::PatientRecords
      end

      # Defines the route and registers the route with application for fetching
      # patient record information
      # Patients Class in Services is initialized if instance does not exist and
      # used to fetch patient information from db
      # If patient record exists in database, PatientsPatient instance is used to
      # fetch patient record information through integration with external vendor
      # 
      def self.registered(app)
        app.helpers Sinatra::JSON

        app.get '/patients/:patient_id' do
          patient_id = params['patient_id'].to_i
          patient = Vandelay::REST::PatientsPatient.patients_srvc.retrieve_one(patient_id)
      
          if patient
            json patient.attributes.to_hash
          else
            status 404
            json({ error: 'Patient not found' })
          end
        end

        app.get '/patients/:patient_id/record' do
          patient_id = params['patient_id'].to_i
          patient = Vandelay::REST::PatientsPatient.patients_srvc.retrieve_one(patient_id)

          if patient
            records = Vandelay::REST::PatientsPatient.patient_records_srvc.fetch(patient)
            json({
              patient_id: patient.id,
              province: records[:province],
              allergies: records[:allergies],
              num_medical_visits: records[:num_medical_visits]
            })
          else
            status 404
            json({ error: 'Patient not found' })
          end
        end
      end
    end
  end
end