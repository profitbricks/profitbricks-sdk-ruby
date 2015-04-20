module ProfitBricks
  # Location class
  class Location < ProfitBricks::Model

    class << self

      # List all locations.
      def list
        response = ProfitBricks.request(
          method: :get,
          path: "/locations",
          expects: 200
        )
        instantiate_objects(response)
      end

      # Retrieve a location.
      def get(location_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/locations/#{location_id}",
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
