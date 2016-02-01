module ProfitBricks
  # Resource model class
  class Model
    attr_accessor :metadata
    attr_accessor :properties
    attr_accessor :datacenterId
    attr_accessor :serverId
    attr_accessor :nicId
    attr_accessor :requestId

    def initialize(options = {})
      options.each do |key, value|
        self.class.send :define_method, key do
          instance_variable_get("@#{key}")
        end
        instance_variable_set("@#{key}".to_sym, value)
      end
    end

    def ready?
      status = ProfitBricks::Request.get(self.requestId).status
      if status.metadata['status'] == 'FAILED' then
          raise ProfitBricks::Errors::OperationFailure, status.metadata['message']
      end
      status.metadata['status'] == 'DONE'
    end

    def reload
      # Remove URL host and prefix path from href.
      path = URI(self.href).path
      path.sub!(ProfitBricks::Config.path_prefix, '')
      
      response = ProfitBricks.request(
        method: :get,
        path: path,
        expects: 200
      )

      # Find cleaner method to set the variable instances on reload.
      if response
        if @metadata
          @metadata = @metadata.merge!(response['metadata'])
        else
          instance_variable_set(:@metadata, response['metadata'])
        end

        if @properties
          @properties = @properties.merge!(response['properties'])
        else
          instance_variable_set(:@properties, response['properties'])
        end
      end
      self
    end

    def wait_for(timeout = ProfitBricks::Config.timeout, interval = 1, &block)
      reload_has_succeeded = false
      duration = ProfitBricks.wait_for(timeout, interval) do # Note that duration = false if it times out
        # if reload
        if ready?
          reload_has_succeeded = true
          instance_eval(&block)
        else
          false
        end
      end
      if reload_has_succeeded
        return duration # false if timeout; otherwise {:duration => elapsed time }
      else
        raise StandardError, "Reload failed, #{self.class} #{self.id} not present."
      end
    end

    private

    # Convert text to JSON.
    def self.parse_json(body)
      JSON.parse(body) unless body.nil? || body.empty?
    rescue JSON::ParserError => error
      raise error
    end

    # Add parent resource ID's to response resources. This will provide
    # convenient ID instance variable for subsequent methods.
    def self.add_parent_identities(response)
      uri = URI(response['href']).path
      if response.key?('items') then
        response['items'].each do |item|
          item.merge!(extract_identities(uri))
        end
      else
        response.merge!(extract_identities(uri))
      end
    end

    def self.extract_identities(uri)
      identities = {}
      if match = uri.match(/datacenters\/([-a-f0-9]+)/i) then
          identities['datacenterId'] = match[1]
      end
      if match = uri.match(/servers\/([-a-f0-9]+)/i) then
          identities['serverId'] = match[1]
      end
      if match = uri.match(/nics\/([-a-f0-9]+)/i) then
          identities['nicId'] = match[1]
      end
      identities
    end

    # Construct Ruby objects from API response.
    def self.instantiate_objects(response)
      if response['type'] == 'collection'
        response['items'].map { |item| new(item) }
      else
        new(response)
      end
    end

    def self.method_missing(name)
      return self[name] if key? name
      self.each { |key, value| return value if key.to_s.to_sym == name }
      super.method_missing name
    end
  end
end
