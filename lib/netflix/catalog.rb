require 'openssl'
require 'open-uri'
require 'oauth'

module Netflix
  class Catalog

    class CatalogDownloadError < StandardError; end

    def initialize(oauth_consumer)
      @oauth_consumer = oauth_consumer
    end

    attr_accessor :local_file_path, :request_options

    # This will download a full index of every title available for instant
    # streaming into a huge XML file. I don't really recommend running it.
    #
    # Parameters are:
    #   * file_path (String)
    #   * gzipped (boolean - if you want to download it gzipped)
    #
    def download_streaming_index(file_path, gzipped = true)
      self.local_file_path = file_path
      self.request_options = { 'User-Agent' => 'Netflix Ruby - https://github.com/goodfilms/netflix-ruby' }
      self.request_options.merge!({'Accept-Encoding' => 'gzip'}) if gzipped

      request = @oauth_consumer.create_signed_request :get,
                                   'http://api-public.netflix.com/catalog/titles/streaming',
                                   nil,     # oauth token
                                   {},      # body (for post/put)
                                   request_options
      http_client = @oauth_consumer.http
      
      http_client.read_timeout = 240

      download_catalog(http_client, request)
    end

  private
    def download_catalog(http_client, request, limit = 3)
      raise "Too Many Redirects" if limit == 0
      
      redirect_uri = nil

      http_client.request(request) do |response|
        case response
        when Net::HTTPSuccess
          write_catalog_response(response)
        when Net::HTTPRedirection
          # set this to request *outside* the current request block
          # so that it doesn't hold the original request open like
          # a nasty version of inception
          redirect_uri = URI.parse(response['location'])
        else
          response.error!
        end
      end

      if redirect_uri
        # create a new client/request and try again
        new_client = Net::HTTP.new(redirect_uri.host, redirect_uri.port)
        new_request = Net::HTTP::Get.new(redirect_uri.request_uri, request_options)

        download_catalog(new_client, new_request, limit - 1)
      end
    end

    def write_catalog_response(response)
      file_open_mode = response.header['Content-Encoding'] == 'gzip' ? 'wb' : 'w'

      File.open(local_file_path, file_open_mode) do |file|
        response.read_body(file)
      end
    end

  end
end
