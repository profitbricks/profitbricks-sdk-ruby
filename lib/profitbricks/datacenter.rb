module ProfitBricks
  # Datacenter class
  class Datacenter < ProfitBricks::Model
    def delete
      ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.id}",
        expects: 202
      )
    end

    def update(options = {})
      response = ProfitBricks.request(
        path: "/datacenters/#{self.id}",
        method: :patch,
        expects: 202,
        body: options.to_json
      )
      if response
        # @properties = @properties.merge!(response['properties'])
        @properties.merge!(response['properties'])
      end
      self
    end

    def list_servers
      ProfitBricks::Server.list(self.id)
    end

    def get_server(server_id)
      ProfitBricks::Server.get(self.id, server_id)
    end

    def create_server(options = {})
      ProfitBricks::Server.create(self.id, options)
    end

    def list_volumes
      ProfitBricks::Volume.list(self.id)
    end

    def get_volume(volume_id)
      ProfitBricks::Volume.get(self.id, nil, volume_id)
    end

    def create_volume(options = {})
      ProfitBricks::Volume.create(self.id, options)
    end

    def list_loadbalancers
      ProfitBricks::Loadbalancer.list(self.id)
    end

    def get_loadbalancer(loadbalancer_id)
      ProfitBricks::Loadbalancer.get(self.id, loadbalancer_id)
    end

    def create_loadbalancer(options = {})
      ProfitBricks::Loadbalancer.create(self.id, options)
    end

    def list_lans
      ProfitBricks::LAN.list(self.id)
    end

    def get_lan(lan_id)
      ProfitBricks::LAN.get(self.id, lan_id)
    end

    def create_lan(options = {})
      ProfitBricks::LAN.create(self.id, options)
    end

    alias_method :server, :get_server
    alias_method :servers, :list_servers
    alias_method :volume, :get_volume
    alias_method :volumes, :list_volumes
    alias_method :loadbalancer, :get_loadbalancer
    alias_method :loadbalancers, :list_loadbalancers
    alias_method :lan, :get_lan
    alias_method :lans, :list_lans

    class << self
      def create(options = {})
        response = ProfitBricks.request(
          method: :post,
          path: '/datacenters',
          body: { properties: options }.to_json,
          expects: 202
        )
        instantiate_objects(response)
      end

      def list
        response = ProfitBricks.request(
          method: :get,
          path: '/datacenters',
          expects: 200
        )
        instantiate_objects(response)
      end

      def get(datacenter_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}",
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
