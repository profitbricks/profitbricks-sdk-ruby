module ProfitBricks
  # Snapshot class
  class Snapshot < ProfitBricks::Model

    # Delete the snapshot.
    def delete
      response = ProfitBricks.request(
        method: :delete,
        path: "/snapshots/#{self.id}",
        expects: 202
      )
      self.requestId = response[:requestId]
      self
    end

    # Update the snapshot.
    def update(options = {})
      response = ProfitBricks.request(
        method: :patch,
        path: "/snapshots/#{self.id}",
        expects: 202,
        body: options.to_json
      )
      if response
        self.requestId = response['requestId']
        @properties = @properties.merge(response['properties'])
      end
      self
    end

    # Restore snapshot to volume.
    def restore(datacenter_id, volume_id)
      volume = ProfitBricks::Volume.get(datacenter_id, nil, volume_id)
      volume.restore_snapshot(self.id)
    end

    class << self

      # Create snapshot from volume.
      def create(datacenter_id, volume_id, options = {})
        volume = ProfitBricks::Volume.get(datacenter_id, nil, volume_id)
        volume.create_snapshot(options)
      end

      # Testing snapshot create from within Snapshot class, but currently
      # relying on Volume class due to lack of datacenter ID in response.
      #
      # def create(datacenter_id, volume_id, options = {})
      #   response = ProfitBricks.request(
      #     method: :post,
      #     path: "/datacenters/#{datacenter_id}/volumes/#{volume_id}/create-snapshot",
      #     expects: 202,
      #     headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      #     body: URI.encode_www_form(options)
      #   )
      #   add_parent_identities(response)
      #   instatiate_objects(response)
      # end

      # List all snapshots.
      def list
        response = ProfitBricks.request(
          method: :get,
          path: '/snapshots',
          expects: 200
        )
        instantiate_objects(response)
      end

      # Retrieve an snapshot.
      def get(snapshot_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/snapshots/#{snapshot_id}",
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
