# ProfitBricks SDK Ruby module
module ProfitBricks
  def self.configure(&block)
    # Configuration variable defaults
    ProfitBricks::Config.timeout = 60
    ProfitBricks::Config.interval = 5
    ProfitBricks::Config.depth = 1
    ProfitBricks::Config.global_classes = true
    ProfitBricks::Config.debug = false
    ProfitBricks::Config.protocol = 'https'
    ProfitBricks::Config.port = '443'
    ProfitBricks::Config.path_prefix = 'cloudapi/v3'
    yield ProfitBricks::Config

    if ProfitBricks::Config.host
      url = construct_url
    else
      url = ProfitBricks::Config.url || 'https://api.profitbricks.com/cloudapi/v3'
    end

    params = {
      user: ProfitBricks::Config.username,
      password: ProfitBricks::Config.password,
      debug: ProfitBricks::Config.debug,
      omit_default_port: true,
      query: { depth: ProfitBricks::Config.depth }
    }

    @client = Excon.new(url, params)
    @client

    ProfitBricks.client = @client

    # Flatten module namespace.
    if ProfitBricks::Config.global_classes
      ProfitBricks.constants.select {
        |c| Class === ProfitBricks.const_get(c)
      }.each do |klass|
        next if klass == :Config
        unless Kernel.const_defined?(klass)
          Kernel.const_set(klass, ProfitBricks.const_get(klass))
        end
      end
    end
  end

  private

  def self.request(params)
    begin
      params = add_headers(params)
      response = ProfitBricks.client.request(prepend_path_prefix(params))
    rescue Excon::Errors::Unauthorized => error
      raise error, parse_json(error.response.body)['messages']
    rescue Excon::Errors::HTTPStatusError => error
      raise error, parse_json(error.response.body)['messages']
    rescue Excon::Errors::InternalServerError => error
      raise error, parse_json(error.response.body)['messages']
    end
    add_request_id(response)
  end

  def self.client=(client)
    @client = client
  end

  def self.client
    @client
  end

  def self.add_request_id(response)
    location ||= response.headers['Location']
    request_id ||= location.match(/requests\/([-a-f0-9]+)/i)[1] unless location.nil?
    body = parse_json(response.body)

    if body.nil?
      body = { requestId: request_id }
    else
      body['requestId'] = request_id
    end
    body
  end

  def self.parse_json(body)
    JSON.parse(body) unless body.nil? || body.empty?
  rescue JSON::ParserError => error
    raise error
  end

  def self.add_headers(params)
    params[:headers] ||= {}
    params[:headers].merge!(ProfitBricks::Config.headers) if ProfitBricks::Config.headers

    if params[:headers]['User-Agent']
      params[:headers]['User-Agent'] = "profitbricks-ruby-sdk/#{ProfitBricks::VERSION} " + params[:headers]['User-Agent']
    else
      params[:headers]['User-Agent'] = "profitbricks-ruby-sdk/#{ProfitBricks::VERSION}"
    end

    unless params[:headers].key?('Content-Type')
      params[:headers]['Content-Type'] = content_type(params[:method])
    end
    params
  end

  def self.content_type(method)
    'application/json'
  end

  def self.prepend_path_prefix(params)
    return params unless ProfitBricks::Config.path_prefix

    path_prefix = ProfitBricks::Config.path_prefix.sub(/\/$/, '')
    params[:path] = params[:path].sub(/^\//, '')
    params[:path] = "#{path_prefix}/#{params[:path]}"
    params
  end

  def self.construct_url
    "#{ProfitBricks::Config.protocol}://" \
    "#{ProfitBricks::Config.host}:" \
    "#{ProfitBricks::Config.port}" \
    "#{ProfitBricks::Config.path_prefix}"
  end

  def self.get_class(name, options = {})
    klass = name.camelcase
    klass = options[:class_name].to_s.camelcase if options[:class_name]
    if ProfitBricks.const_defined?(klass)
      klass = ProfitBricks.const_get(klass)
    else
      begin
        require "profitbricks/#{klass.downcase}"
        klass = ProfitBricks.const_get(klass)
      rescue LoadError
        raise LoadError.new("Invalid association, could not locate the class '#{klass}'")
      end
    end
    klass
  end
end
