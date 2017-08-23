module ProfitBricks
  # User class
  class User < ProfitBricks::Model
    # Delete the user.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/um/users/#{id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the user.
    def update(options = {})
      response = ProfitBricks.request(
        method: :put,
        path: "/um/users/#{id}",
        expects: 202,
        body: { properties: options }.to_json
      )
      if response
        self.requestId = response['requestId']
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    class << self
      # Create a new user.
      def create(options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/um/users",
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all users.
      def list(options = {})
        path = "/um/users"
        path = "/um/groups/#{options[:group_id]}/users" if options[:group_id]
        response = ProfitBricks.request(
          method: :get,
          path: path,
          expects: 200,
          query: options
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve an user.
      def get(user_id,options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/um/users/#{user_id}",
          expects: 200,
          query: options
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Add an user to a group
      def add_to_group(group_id, user_id)
        response = ProfitBricks.request(
          method: :post,
          path: "/um/groups/#{group_id}/users",
          expects: 202,
          body: {id: user_id}.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Remove an user from a group
      def remove_from_group(group_id, user_id)
        response = ProfitBricks.request(
          method: :delete,
          path: "/um/groups/#{group_id}/users/#{user_id}",
          expects: 202
        )
        return true
      end
    end
  end
end
