module ProfitBricks
  # Server class
  class Server < ProfitBricks::Model
    # Delete the server.
    def delete
      ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}",
        expects: 202
      )
    end

    # Update the server.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}",
        expects: 202,
        body: options.to_json
      )
      if response
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    # Start the server.
    def start
      server_control('start')
    end

    # Stop the server.
    def stop
      server_control('stop')
    end

    # Reboot the server.
    def reboot
      server_control('reboot')
    end

    # List server volumes.
    def list_volumes
      ProfitBricks::Volume.list(self.datacenterId, self.id)
    end

    # Retrieve server volume.
    def get_volume(volume_id)
      ProfitBricks::Volume.get(self.datacenterId, self.id, volume_id)
    end

    # Attach volume to server.
    def attach_volume(volume_id)
      volume = ProfitBricks::Volume.get(self.datacenterId, nil, volume_id)
      volume.attach(self.id)
    end

    # Detach volume from server.
    def detach_volume(volume_id)
      volume = ProfitBricks::Volume.get(self.datacenterId, nil, volume_id)
      volume.detach(self.id)
    end

    def list_cdroms
      response = ProfitBricks.request(
        method: :get,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}/cdroms",
        expects: 200
      )
      self.class.instantiate_objects(response)
    end

    def get_cdrom(cdrom_id)
      response = ProfitBricks.request(
        method: :get,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}/cdroms/#{cdrom_id}",
        expects: 200
      )
      self.class.instantiate_objects(response)
    end

    def attach_cdrom(cdrom_id)
      response = ProfitBricks.request(
        method: :post,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}/cdroms",
        expects: 202,
        body: { id: cdrom_id }.to_json
      )
      self.class.instantiate_objects(response)
    end

    def detach_cdrom(cdrom_id)
      ProfitBricks.request(
        method: :delete,
        path: "/datacenters/#{self.datacenterId}/servers/#{self.id}/cdroms/#{cdrom_id}",
        expects: 202
      )
    end

    # List server NICs.
    def list_nics
      ProfitBricks::NIC.list(self.datacenterId, self.id)
    end

    # Retrieve server NIC.
    def get_nic(nic_id)
      ProfitBricks::NIC.get(self.datacenterId, self.id, nic_id)
    end

    # Create server NIC.
    def create_nic(options = {})
      ProfitBricks::NIC.create(self.datacenterId, self.id, options)
    end

    alias_method :nics, :list_nics
    alias_method :nic, :get_nic

    class << self
      # Create a new server.

      def create(datacenter_id, options = {})
        entities = {}

        # Retrieve volumes collection if present and generate appropriate JSON.
        if options.key?(:volumes)
          entities[:volumes] = collect_entities(options.delete(:volumes))
        end

        # Retrieve nics collection if present and generate appropriate JSON.
        if options.key?(:nics)
          entities[:nics] = collect_entities(options.delete(:nics))
        end

        response = ProfitBricks.request(
          method: :post,
          path: "/datacenters/#{datacenter_id}/servers",
          expects: 202,
          body: { properties: options, entities: entities }.to_json
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      # List all servers by datacenter.
      def list(datacenter_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end

      def get(datacenter_id, server_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/datacenters/#{datacenter_id}/servers/#{server_id}",
          expects: 200
        )
        add_parent_identities(response)
        instantiate_objects(response)
      end
    end

    private

    def self.collect_entities(entities)
      if entities.is_a?(Array) && entities.length > 0
        items = []
        entities.each do |entity|
          if entity.key?(:firewallrules)
            subentities = collect_entities(entity.delete(:firewallrules))
            items << {
              properties: entity,
              entities: { firewallrules: subentities }
            }
          else
            items << { properties: entity }
          end
        end
        { items: items }
      end
    end

    def server_control(operation)
      ProfitBricks.request(
        method: :post,
        path: "/datacenters/#{self.datacenterId}/servers/#{id}/#{operation}",
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        expects: 202
      )
    end
  end
end
