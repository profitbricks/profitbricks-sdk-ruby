module ProfitBricks
  # NIC class
  class NIC < ProfitBricks::Model

    # Delete the NIC.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.serverId}/nics/#{self.id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the NIC.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.serverId}/nics/#{self.id}",
        expects: 202,
        body: options.to_json
      )
      if response
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    # List all NIC firewall rules
    def list_firewall_rules
      ProfitBricks::Firewall.list(self.datacenterId, self.serverId, self.id)
    end

    # Retrieve NIC firewall rule
    def get_firewall_rule(fwrule_id)
      ProfitBricks::Firewall.get(self.datacenterId, self.serverId, self.id, fwrule_id)
    end

    # Create NIC firewall rule
    def create_firewall_rule(options = {})
      ProfitBricks::Firewall.create(self.datacenterId, self.serverId, self.id, options)
    end 

    alias_method :list_fwrules, :list_firewall_rules
    alias_method :fwrules, :list_firewall_rules
    alias_method :get_fwrule, :get_firewall_rule
    alias_method :fwrule, :get_firewall_rule
    alias_method :create_fwrule, :create_firewall_rule

    class << self

      # Create a new NIC.
      def create(datacenter_id, server_id, options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics",
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all NICs assigned to a server.
      def list(datacenter_id, server_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a NIC assigned to a datacenter.
      def get(datacenter_id, server_id, nic_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}/nics/#{nic_id}",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end
  end
end
