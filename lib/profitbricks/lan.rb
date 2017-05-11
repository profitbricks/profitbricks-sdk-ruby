module ProfitBricks
  # LAN class
  class LAN < ProfitBricks::Model

    # Delete the LAN.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.datacenterId}/lans/#{self.id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
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
        self.requestId = response['requestId']
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    class << self

      # Create a new LAN.
      def create(datacenter_id, options = {})
        entities = {}
        # Retrieve nics collection if present and generate appropriate JSON.
        if options.key?('nics')
          entities[:nics] =collect_entities(options.delete('nics'))
        end
        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/lans",
          expects: 202,
          body: { properties: options, entities: entities }.to_json
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

    private

    def self.collect_entities(entities)
      items = []
      if entities.is_a?(Array) && entities.length > 0
        entities.each do |entity|
          items << { id: entity }
        end
        {items: items}
      end
    end
  end
end
