require 'signature'
require 'multi_json'

module ThunderPush

  class Client

    attr_accessor :scheme, :publickey, :privatekey, :hostname, :port
    attr_writer :connect_timeout, :send_timeout, :receive_timeout,
                :keep_alive_timeout

    def initialize(options={})
      options = {
        port: 5678,
        scheme: 'http',
        hostname: '127.0.0.1',
        publickey: nil,
        privatekey: nil
      }.merge options

      @encrypted = false

      @scheme, @publickey, @privatekey, @hostname, @port = options.values_at(
        :scheme, :publickey, :privatekey, :hostname, :port
      )

      # Default timeouts
      @connect_timeout = 5
      @send_timeout = 5
      @receive_timeout = 5
      @keep_alive_timeout = 30
    end

    def authenticate(publickey, privatekey)
      @publickey, @privatekey = publickey, privatekey
    end

    # @private Returns the authentication token for the client
    def authentication_token
      Signature::Token.new(@publickey, @privatekey)
    end

    def config(&block)
      raise ConfigurationError, 'You need a block' unless block_given?
      yield self
    end

    def encrypted=(bool)
      @scheme = bool ? 'https' : 'http'
      # Configure port if it hasn't already been configured
      @port = bool ? 443 : 80
    end

    def encrypted?
      scheme == 'https'
    end

    def get(path, params)
      Resource.new(self, "/#{publickey}#{path}").get params
    end

    def get_async(path, params)
      Resource.new(self, "/#{publickey}#{path}").get_async params
    end

    def post(path, body)
      Resource.new(self, "/#{publickey}#{path}").post body
    end

    def post_async(path, body)
      Resource.new(self, "/#{publickey}#{path}").post_async body
    end

    # @private Construct a net/http http client
    def sync_http_client
      @client ||= begin
        require 'httpclient'

        HTTPClient.new(default_header: {'X-Thunder-Secret-Key' => @privatekey}).tap do |c|
          c.connect_timeout = @connect_timeout
          c.send_timeout = @send_timeout
          c.receive_timeout = @receive_timeout
          c.keep_alive_timeout = @keep_alive_timeout
        end
      end
    end

    # Convenience method to set all timeouts to the same value (in seconds).
    # For more control, use the individual writers.
    def timeout=(value)
      @connect_timeout, @send_timeout, @receive_timeout = value, value, value
    end

    # Trigger an event on one or more channels
    #
    # POST /api/[api_version]/channels/[channel]/
    #
    # @param channels [String or Array] 1-10 channel names
    # @param event_name [String]
    # @param data [Object] Event data to be triggered in javascript.
    #   Objects other than strings will be converted to JSON
    #
    # @return [Hash] See Thunderpush API docs
    #
    # @raise [Thunderpushcli::Error] Unsuccessful response - see the error message
    # @raise [Thunderpushcli::HTTPError] Error raised inside http client. The original error is wrapped in error.original_error
    #
    def trigger(channels, event, data)
      channels = Array(channels) unless channels.is_a? Array
      channels.each do |channel|
        post("/channels/#{channel}/", trigger_params(channel, event, data))
      end
    end

    # Trigger an event on one or more channels
    #
    # POST /apps/[app_id]/events
    #
    # @param channels [String or Array] 1-10 channel names
    # @param event_name [String]
    # @param data [Object] Event data to be triggered in javascript.
    #   Objects other than strings will be converted to JSON
    #
    # @return [Hash] See Thunderpush API docs
    #
    # @raise [Thunderpushcli::Error] Unsuccessful response - see the error message
    # @raise [Thunderpushcli::HTTPError] Error raised inside http client. The original error is wrapped in error.original_error
    #
    def trigger_async(channels, event, data)
      channels = Array(channels) unless channels.is_a? Array
      channels.each do |channel|
        post_async("/channels/#{channel}/", trigger_params(channel, event, data))
      end
    end

    # Configure Thunderpush connection by providing a url rather than specifying
    # scheme, key, secret, and app_id separately.
    #
    # @example
    #   Thunderpush.default_client.url = http://key:secret@127.0.0.1:5678
    #
    def url=(str)
      regex = /^(?<scheme>http|https):\/\/((?<publickey>[\w-]+)(:(?<privatekey>[\w-]+){1})?@)?(?<hostname>[\w\.-]+)(:(?<port>[\d]+))?/
      match = str.match regex
      @scheme     = match[:scheme]     unless match[:scheme].nil?
      self.encrypted= true if scheme == 'https'
      @port       = match[:port].to_i  unless match[:port].nil?
      @hostname   = match[:hostname]   unless match[:hostname].nil?
      @publickey  = match[:publickey]  unless match[:publickey].nil?
      @privatekey = match[:privatekey] unless match[:privatekey].nil?
    end

    # @private Builds a url for this app, optionally appending a path
    def url(path = '')
      path = "/#{path}" unless path.start_with? '/'
      URI::Generic.build({
        :scheme => @scheme,
        :host => @hostname,
        :port => @port,
        :path => "/api/#{ThunderPush::API_VERSION}#{path}"
      })
    end

    protected

    def trigger_params(channel, event_name, data)
      data = {
          channel: channel,
          event: event_name,
          data: data
      }
      begin
        MultiJson.encode(data)
      rescue MultiJson::DecodeError => e
        ThunderPush.logger.error("Could not convert #{data.inspect} into JSON")
        raise e
      end
    end
  end
end