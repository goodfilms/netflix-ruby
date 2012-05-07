require 'openssl'
require 'open-uri'
require 'oauth'

module Netflix
  class Catalog
    def initialize(oauth_consumer)
      @oauth_consumer = oauth_consumer
    end

    def index
      request = @oauth_consumer.create_signed_request :get,
                                               '/catalog/titles/index',
                                               nil,
                                               max_results: 25

      @oauth_consumer.http.request(request) do |response|
        response.read_body do |chunk|
          puts chunk
        end
      end
    end
  end
end
