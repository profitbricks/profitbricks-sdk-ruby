module ProfitBricks
  # Request class
  class Request < ProfitBricks::Model
    # Retrieve status of a request.
    def status
      response = ProfitBricks.request(
        method: :get,
        path: "/requests/#{self.id}/status",
        expects: 200
      )
      self.class.instantiate_objects(response)
    end

    class << self
      # List all requests.
      def list
        response = ProfitBricks.request(
          method: :get,
          path: '/requests',
          expects: 200
        )
        instantiate_objects(response)
      end

      # Retrieve a request.
      def get(request_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/requests/#{request_id}",
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
