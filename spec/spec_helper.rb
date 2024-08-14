# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../boot'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'mock_redis'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) do
   redis = MockRedis.new
   redis.flushdb
  end
end

def app
  Sinatra::Application
end
