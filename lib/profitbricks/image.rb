module ProfitBricks
  # Image class
  class Image < ProfitBricks::Model
    # Delete the image.
    def delete
      ProfitBricks.request(
        method: :delete,
        path: "/images/#{id}",
        expects: 202
      )
    end

    # Update the image.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/images/#{id}",
        expects: 202,
        body: options.to_json
      )
      if response
        self.requestId = response['requestId']
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    class << self
      # List all images.
      def list(options = {})

        response = ProfitBricks.request(
          method: :get,
          path: '/images/',
          expects: 200,
          query: options
        )
        instantiate_objects(response)
      end

      # Retrieve an image.
      def get(image_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/images/#{image_id}",
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
