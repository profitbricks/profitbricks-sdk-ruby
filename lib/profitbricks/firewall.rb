module ProfitBricks
  # Firewall class
  class Firewall < ProfitBricks::Model
    # Delete the firewall rule.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{datacenterId}/servers/#{serverId}/nics/#{nicId}/firewallrules/#{id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the firewall rule.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/datacenters/#{datacenterId}/servers/#{serverId}/nics/#{nicId}/firewallrules/#{id}",
        expects: 202,
        body: options.to_json
      )
      @properties = @properties.merge(response['properties'])
      self
    end

    class << self
      # Create a new firewall rule.
      def create(datacenter_id, server_id, nic_id, options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics/#{nic_id}/firewallrules",
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all firewall rules assigned to a NIC.
      def list(datacenter_id, server_id, nic_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics/#{nic_id}/firewallrules",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a firewall rule assigned to a NIC.
      def get(datacenter_id, server_id, nic_id, fwrule_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics/#{nic_id}/firewallrules/#{fwrule_id}",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end
  end
end
