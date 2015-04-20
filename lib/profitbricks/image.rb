module ProfitBricks
  # Image class
  class Image < ProfitBricks::Model

    # Delete the image.
    def delete
      ProfitBricks.request(
        method: :delete,
        path: "/images/#{self.id}",
        expects: 202
      )
    end

    # Update the image.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/images/#{self.id}",
        expects: 202,
        body: options.to_json
      )
      if response
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    class << self

      # List all images.
      def list
        response = ProfitBricks.request(
          method: :get,
          path: '/images',
          expects: 200
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
