module ProfitBricks
  # Contract Resource class
  class Contract < ProfitBricks::Model

    class << self
      # Retrieve a contract.
      def get(options = {})
        response = ProfitBricks.request(
          method: :get,
          path: "/contracts",
          expects: 200,
          query: options
        )
        instantiate_objects(response)
      end

      # Retrieve a contract by contract number.
      def get_by_contract_id(contract_id)
        response = ProfitBricks.request(
          method: :get,
          path: "/contracts",
          headers: { 'PB-Contract-Number' => "#{contract_id}" },
          expects: 200
        )
        instantiate_objects(response)
      end
    end
  end
end
