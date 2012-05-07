require 'openssl'
require 'open-uri'
require 'oauth'

module Netflix
  class Catalog
    def initialize(oauth_consumer)
      @oauth_consumer = oauth_consumer
    end

    # This will download a full index of every title available for instant
    # streaming into a huge XML file. I don't really recommend running it.
    def download_index(file_path)
      request = @oauth_consumer.create_signed_request :get,
                                               'http://api.netflix.com/catalog/titles/index'

      

      File.open(file_path, 'w') do |file|
        @oauth_consumer.http.request(request) do |response|
           response.read_body do |chunk|
             file.write(chunk)
           end
        end
      end
    end

  end
end
