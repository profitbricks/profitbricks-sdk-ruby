module ProfitBricks
  # IPBlock class
  class IPBlock < ProfitBricks::Model
    # Release an IP block.
    def release
      ProfitBricks.request(
        method: :delete,
        path: "/ipblocks/#{id}",
        expects: 202
      )
    end

    alias_method :delete, :release

    class << self
      # Reserve an IP block.
      #
      # ==== Parameters
      # * +options+<Hash>:
      #   - +location+<String> - *Required*, must be one of the following locations:
      #     * +us/las+ - United States / Las Vegas
      #     * +de/fra+ - Germany / Frankfurt
      #     * +de/fkb+ - Germany / Karlsruhe
      #   - +size+<Integer> - *Required*, the desired size of the IP block.
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
      #   - +etag+
      # * +properties+<Hash>:
      #   - +size+<Integer> - Size of the IP block
      #   - +ips+<Array> - A collection of IP addresses associated with the IP block
      #   - +location+<String> - Location of IP block
      #
      def reserve(options = {})
        response = ProfitBricks.request(
          method: :post,
          path: '/ipblocks',
          expects: 202,
          body: { properties: options }.to_json
        )
        instantiate_objects(response)
      end

      # List all reserved IP blocks.
      def list
        response = ProfitBricks.request(
          method: :get,
          path: '/ipblocks',
          expects: 200
        )
        instantiate_objects(response)
      end

      # Retrieve a reserved IP block.
      def get(ipblock_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/ipblocks/#{ipblock_id}",
          expects: 200
        )
        instantiate_objects(response)
      end

      alias_method :create, :reserve
    end
  end
end
