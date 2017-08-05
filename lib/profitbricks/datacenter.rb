module ProfitBricks
  # Datacenter class
  class Datacenter < ProfitBricks::Model
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    def update(options = {})
      response = ProfitBricks.request(
        path: "/datacenters/#{id}",
        method: :patch,
        expects: 202,
        body: options.to_json
      )
      if response
        self.requestId = response['requestId']
        @properties.merge!(response['properties'])
      end
      self
    end

    def list_servers
      ProfitBricks::Server.list(id)
    end

    def get_server(server_id)
      ProfitBricks::Server.get(id, server_id)
    end

    def create_server(options = {})
      ProfitBricks::Server.create(id, options)
    end

    def list_volumes
      ProfitBricks::Volume.list(id)
    end

    def get_volume(volume_id)
      ProfitBricks::Volume.get(id, nil, volume_id)
    end

    def create_volume(options = {})
      ProfitBricks::Volume.create(id, options)
    end

    def list_loadbalancers
      ProfitBricks::Loadbalancer.list(id)
    end

    def get_loadbalancer(loadbalancer_id)
      ProfitBricks::Loadbalancer.get(id, loadbalancer_id)
    end

    def create_loadbalancer(options = {})
      ProfitBricks::Loadbalancer.create(id, options)
    end

    def list_lans
      ProfitBricks::LAN.list(id)
    end

    def get_lan(lan_id)
      ProfitBricks::LAN.get(id, lan_id)
    end

    def create_lan(options = {})
      ProfitBricks::LAN.create(id, options)
    end

    alias server get_server
    alias servers list_servers
    alias volume get_volume
    alias volumes list_volumes
    alias loadbalancer get_loadbalancer
    alias loadbalancers list_loadbalancers
    alias lan get_lan
    alias lans list_lans

    class << self
      def create(options = {})
        entities = {}

        # Retrieve servers collection if present and generate appropriate JSON.
        if options.key?(:servers)
          entities[:servers] = collect_entities(options.delete(:servers))
        end

        # Retrieve volumes collection if present and generate appropriate JSON.
        if options.key?(:volumes)
          entities[:volumes] = collect_entities(options.delete(:volumes))
        end

        # Retrieve volumes collection if present and generate appropriate JSON.
        if options.key?(:loadbalancers)
          entities[:loadbalancers] = collect_entities(options.delete(:loadbalancers))
        end

        # Retrieve volumes collection if present and generate appropriate JSON.
        if options.key?(:lans)
          entities[:lans] = collect_entities(options.delete(:lans))
        end

        response = ProfitBricks.request(
          method: :post,
          path: '/datacenters',
          body: { properties: options, entities: entities }.to_json,
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

    private

    def self.collect_entities(entities)
      if entities.is_a?(Array) && entities.length > 0
        items = []
        entities.each do |entity|
          if entity.key?(:volumes)
            subentities = collect_entities(entity.delete(:volumes))
            items << {
              properties: entity,
              entities: { volumes: subentities }
            }
          else
            items << { properties: entity }
          end
        end
        { items: items }
      end
    end
  end
end
