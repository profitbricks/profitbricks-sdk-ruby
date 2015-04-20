module ProfitBricks
  # LAN class
  class LAN < ProfitBricks::Model

    # Delete the LAN.
    def delete
      ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.datacenterId}/lans/#{self.id}",
        expects: 202
      )
    end

    # Update the LAN.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/datacenters/#{self.datacenterId}/lans/#{self.id}",
        expects: 202,
        body: options.to_json
      )
      if response
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    # List LAN members.
    def list_members
      response = ProfitBricks.request(
        method: :get,
        path: "/datacenters/#{self.datacenterId}/lans/#{self.id}/nics",
        expects: 200,
      )
      self.class.instantiate_objects(response)
    end

    class << self

      # Create a new LAN.
      def create(datacenter_id, options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/lans",
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all LANs under a datacenter.
      def list(datacenter_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/lans",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a LAN under a datacenter.
      def get(datacenter_id, lan_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/lans/#{lan_id}",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end
  end
end
