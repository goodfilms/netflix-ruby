require 'netflix/json_resource'

module Netflix
  class RentalHistory < JsonResource
  
    MAX_RESULTS = 500

    define_getter :etag, :rental_history_item

    def initialize(oauth_access_token, user_id)
      @oauth_access_token = oauth_access_token
      @user_id = user_id
      super(retrieve)
    end

    def discs
      if rental_history_item
        # Sometime netflix will give us back an empty
        # string instead of a proper entry
        rental_history_item.select { |history_item|
            history_item.is_a?(Hash)
          }.map { |history_item| 
            Disc.new(history_item) 
          }
      else
        []
      end
    end

  private
    def retrieve(etag = nil)
      url = "/users/#{@user_id}/rental_history?max_results=#{MAX_RESULTS}&output=json"
      if (etag)
        response = @oauth_access_token.get(url, { 'etag' => etag.to_s })
      else
        response = @oauth_access_token.get(url)
      end
      @body = response.body
      JSON.parse(@body)["rental_history"]
    end

  end
end
