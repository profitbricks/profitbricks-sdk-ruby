module ProfitBricks
  # Group class
  class Group < ProfitBricks::Model
    # Delete the group.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/um/groups/#{id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the group.
    def update(options = {})
      response = ProfitBricks.request(
        method: :put,
        path: "/um/groups/#{id}",
        expects: 202,
        body: { properties: options }.to_json
      )
      if response
        self.requestId = response['requestId']
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    # Add an user to the group
    def add_user(user_id)
      ProfitBricks::User.add_to_group(id, user_id)
    end

    # Remove an user from the group
    def remove_user(user_id)
      ProfitBricks::User.remove_from_group(id, user_id)
    end

    class << self
      # Create a new group.
      def create(options = {})
        response = ProfitBricks.request(
          method: :post,
          path: '/um/groups/',
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all groups.
      def list(options = {})
        response = ProfitBricks.request(
          method: :get,
          path: '/um/groups/',
          expects: 200,
          query: options
        )
        instantiate_objects(response)
      end

      # Retrieve a group.
      def get(group_id,options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/um/groups/#{group_id}",
          expects: 200,
          query: options
        )
        instantiate_objects(response)
      end
  end
end
end
