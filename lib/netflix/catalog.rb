require 'openssl'
require 'open-uri'
require 'oauth'

module Netflix
  class Catalog

    class CatalogDownloadError < StandardError; end

    def initialize(oauth_consumer)
      @oauth_consumer = oauth_consumer
    end

    # This will download a full index of every title available for instant
    # streaming into a huge XML file. I don't really recommend running it.
    #
    # Parameters are:
    #   * file_path (String)
    #   * gzipped (boolean - if you want to download it gzipped)
    #
    def download_index(file_path, gzipped = false)
      request_options = gzipped ? {'Accept-Encoding' => 'gzip'} : {}

      request = @oauth_consumer.create_signed_request :get,
                                   'http://api.netflix.com/catalog/titles/index',
                                   nil,     # oauth token
                                   {},      # body (for post/put)
                                   request_options
      
      @oauth_consumer.http.request(request) do |response|
        if response.is_a?(Net::HTTPSuccess)
          file_open_mode = response.header['Content-Encoding'] == 'gzip' ? 'wb' : 'w'

          File.open(file_path, file_open_mode) do |file|
            response.read_body(file)
          end
        else
          raise CatalogDownloadError.new("#{response.class} - #{response.code} - #{respone.message}")
        end
      end
    end

  end
end
