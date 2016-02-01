module ProfitBricks
  # Loadbalancer class
  class Loadbalancer < ProfitBricks::Model
    # Delete the loadbalancer.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the loadbalancer.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}",
        expects: 202,
        body: options.to_json
      )
      @properties = @properties.merge(response['properties'])
      self
    end

    def list_balanced_nics
      response = ProfitBricks.request(
        method: :get,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}/balancednics",
        expects: 200
      )
      self.class.instantiate_objects(response)
    end

    def associate_balanced_nic(nic_id)
      response = ProfitBricks.request(
        method: :post,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}/balancednics",
        expects: 202,
        body: { id: nic_id }.to_json
      )
      self.class.instantiate_objects(response)
    end

    def get_balanced_nic(nic_id)
      response = ProfitBricks.request(
        method: :get,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}/balancednics/#{nic_id}",
        expects: 200
      )
      self.class.instantiate_objects(response)
    end

    def remove_balanced_nic(nic_id)
      ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{datacenterId}/loadbalancers/#{id}/balancednics/#{nic_id}",
        expects: 202
      )
    end

    alias_method :list_nics, :list_balanced_nics
    alias_method :associate_nic, :associate_balanced_nic
    alias_method :remove_nic, :remove_balanced_nic

    class << self
      # Create a new loadbalancer.
      #
      # ==== Parameters
      # * +options+<Hash>:
      #   - +name+<String> - *Optional*, name of the loadbalancer
      #   - +ip+<String> - *Optional*, IPv4 address of the loadbalancer
      #   - +dhcp+<Boolean> - *Optional*, Indicates if the loadbalancer will
      #     reserve an IP using DHCP
      #
      # ==== Returns
      # * +id+<String> - Universally unique identifer of resource
      # * +type+<String> - Resource type
      # * +href+<String> - Resource URL representation
      # * +metadata+<Hash>:
      #   - +lastModifiedDate+
      #   - +lastModifiedBy+
      #   - +createdDate+
      #   - +createdBy+
      #   - +state+
      #   - +etag+
      # * +properties+<Hash>:
      #   - +name+<String>
      #   - +ip+<String>
      #   - +dhcp+<Boolean>
      #
      def create(datacenter_id, options = {})
        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/loadbalancers",
          expects: 202,
          body: { properties: options }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all loadbalancers under a datacenter.
      def list(datacenter_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/loadbalancers",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # Retrieve a loadbalancer under a datacenter.
      def get(datacenter_id, loadbalancer_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/loadbalancers/#{loadbalancer_id}",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end
  end
end
