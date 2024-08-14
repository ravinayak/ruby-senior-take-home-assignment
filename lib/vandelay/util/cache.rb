require 'redis'

module Vandelay
  module Util
    class Cache
      # Initializes this class with a redis instance
      #
      def initialize
        @redis = Redis.new(url: "redis://redis:6379/0")
      end

      # Fetches value of given key in Redis if present
      # Sets key, value pair with an expirty of 10 minutes
      # if not present
      # @param [String] key
      # @param [Integer]
      # @return [JSON]
      #
      def fetch(key, expires_in: 600)
        value = @redis.get(key)
        return JSON.parse(value, symbolize_names: true) if value

        # if key is not present, block passed to this method is used to fetch information
        # and persisted in Redis with expiry of 10 minutes
        #
        value = yield
        @redis.setex(key, expires_in, value.to_json)
        value
      end
    end
  end
end
