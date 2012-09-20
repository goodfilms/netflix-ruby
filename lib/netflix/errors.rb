require 'json'

module Netflix
  module Error
    class ResponseError < StandardError
      # standard stuff we get off the http response
      attr_accessor :http_status_code, :http_headers, :response_body

      # custom netflix stuff
      attr_accessor :netflix_status_code, :netflix_sub_code, :netflix_message

      def initialize(code, body, headers)
        self.http_status_code = code
        self.response_body = body
        self.http_headers = headers

        status_hash = JSON.parse(response_body)['status']

        self.netflix_status_code = status_hash['status_code']
        self.netflix_sub_code = status_hash['sub_code']
        self.netflix_message = status_hash['message']

        message = "#{http_status_code}/#{netflix_sub_code || 'unknown'} - #{netflix_message}"

        super(message)
      end
    end

    #4xx level errors
    class ClientError < ResponseError; end
    #5xx level errors
    class ServerError < ResponseError; end
    #400
    class BadRequest < ClientError; end
    #403
    class Forbidden < ClientError; end
    #404
    class NotFound < ClientError; end
    #401
    class Unauthorized < ClientError; end
    #420 (?)
    class RateLimit < ClientError; end

    def self.for(response)
      code = response.code.to_i

      error_class = case code
                    when 400
                      BadRequest
                    when 403
                      Forbidden
                    when 404
                      NotFound
                    when 401
                      Unauthorized
                    when 420
                      RateLimit
                    when 400..499
                      ClientError
                    else
                      ResponseError
                    end

      error_class.new(code, response.body, response.header)
    end
  end
end
