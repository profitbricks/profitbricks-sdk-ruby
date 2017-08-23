module ProfitBricks
  # Resource class
  class Resource < ProfitBricks::Model
    class << self
      # List all resources.
      def list(options = {})
        response = ProfitBricks.request(
          method: :get,
          path: '/um/resources',
          expects: 200,
          query: options
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      def list_by_type(resource_type, options = {})      
        response = ProfitBricks.request(
          method: :get,
          path: "/um/resources/#{resource_type}",
          expects: 200,
          query: options
        )

        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a resource
      def get(resource_type, resource_id, options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/um/resources/#{resource_type}/#{resource_id}",
          expects: 200,
          query: options
        )

        instantiate_objects(response)
      end
    end
  end
end
