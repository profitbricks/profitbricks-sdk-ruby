module ProfitBricks
  class Config
    class << self
      # ProfitBricks URL, default: https://api.profitbricks.com
      attr_accessor :url
      # ProfitBricks username (required)
      attr_accessor :username 
      # ProfitBricks password (required)
      attr_accessor :password
      # ProfitBricks URL protocol, default: https
      attr_accessor :protocol
      # ProfitBricks URL host
      attr_accessor :host
      # ProfitBricks URL port, default: 443
      attr_accessor :port
      # ProfitBricks URL path prefix, default: /rest/
      attr_accessor :path_prefix
      # Custom HTTP request headers
      attr_accessor :headers
      # Disable namespacing the classes, set to false to avoid name conflicts, default: true
      attr_accessor :global_classes
      # Timeout value for wait_for() method, default: 60 seconds
      attr_accessor :timeout
      # Polling interval value for wait_for() method, default: 3 seconds
      attr_accessor :interval
      # Request depth, default: 1
      attr_accessor :depth
      # Enable or disable Excon debugging, default: false
      attr_accessor :debug
    end
  end
end
