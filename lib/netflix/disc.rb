require 'netflix/json_resource'

module Netflix
  class Disc < JsonResource
    define_getter :id, :updated
    
    def title
      @map["title"]["regular"]
    end

    def movie_id
      movie_link = @map["link"].detect { |link| link["rel"] == "http://schemas.netflix.com/catalog/title" }
      movie_link && movie_link["href"]
    end
  end
end
