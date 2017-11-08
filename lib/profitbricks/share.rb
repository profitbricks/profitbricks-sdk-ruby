module ProfitBricks
  # Share class
  class Share < ProfitBricks::Model

    class << self
      # Delete the share.
      def delete(group_id,resource_id)
        response = ProfitBricks.request(
          method: :delete,
          path: "/um/groups/#{group_id}/shares/#{resource_id}",
          expects: 202
        )
        return true
      end

      # Update the share.
      def update(group_id, resource_id, options = {})
        response = ProfitBricks.request(
          method: :put,
          path: "/um/groups/#{group_id}/shares/#{resource_id}",
          expects: 202,
          body: { properties: options }.to_json
        )

        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Create a new share.
      def create(group_id, resource_id, options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/um/groups/#{group_id}/shares/#{resource_id}",
          expects: 202,
          body: { properties: options}.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all shares under a group.
      def list(group_id, options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/um/groups/#{group_id}/shares",
          expects: 200,
          query: options
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a share under a group.
      def get(group_id, share_id, options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/um/groups/#{group_id}/shares/#{share_id}",
          expects: 200,
          query: options
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end
  end
end
