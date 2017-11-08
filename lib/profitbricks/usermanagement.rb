module ProfitBricks
  # UserManagement class
  class UserManagement < ProfitBricks::Model
    class << self
    # List all groups.
    def list_group(options = {})
      ProfitBricks::Group.list(options)
    end

    # Retrieve a group.
    def get_group(group_id)
      ProfitBricks::Group.get(group_id)
    end

    # Create a new group.
    def create_group(options = {})
      ProfitBricks::Group.create(options)
    end

    # List all shares.
    def list_share(group_id, options = {})
      ProfitBricks::Share.list(group_id, options)
    end

    # Retrieve a share.
    def get_share(group_id, share_id)
      ProfitBricks::Share.get(group_id, share_id)
    end

    # Create a new share.
    def create_share(group_id, resource_id, options = {})
      ProfitBricks::Share.create(group_id, resource_id, options)
    end

    # List all groups.
    def list_user(options = {})
      ProfitBricks::User.list(options)
    end

    # Retrieve a user.
    def get_user(user_id)
      ProfitBricks::User.get(user_id)
    end

    # Create a new user.
    def create_user(options = {})
      ProfitBricks::User.create(options)
    end

    # List all resources.
    def list_resource(options = {})
      ProfitBricks::Resource.list(options)
    end

    # Retrieve a resource.
    def get_resoruce(resource_type, resource_id, options = {})
      ProfitBricks::Resource.get(resource_type, resource_id, options)
    end
  end
  end
end
