require 'signature'

module ThunderPush
  class Request
    attr_reader :body, :params

    def initialize(client, verb, uri, params={}, body = nil)
      @client, @verb, @uri = client, verb, uri

      raise ConfigurationError, "Invalid verb ('#{verb}')" unless %w{GET POST}.include? verb.to_s.upcase
      raise ConfigurationError, "Invalid client #{client.inspect}" unless client.is_a? Client
      raise ConfigurationError, "Invalid uri #{uri.inspect}" unless uri.is_a? URI

      @head = {}

      @body = body
      if body
        params[:body_md5] = Digest::MD5.hexdigest(body)
        @head['Content-Type'] = 'application/json'
      end

      request = Signature::Request.new(verb.to_s.upcase, uri.path, params)
      request.sign(client.authentication_token)
      @params = request.signed_params
    end

    def send_sync
      http = @client.sync_http_client

      begin
        response = http.request(@verb, @uri, @params, @body, @head)
      rescue HTTPClient::BadResponseError, HTTPClient::TimeoutError,
          SocketError, Errno::ECONNREFUSED => e
        error = ThunderPush::HTTPError.new("#{e.message} (#{e.class})")
        raise error
      end

      body = response.body ? response.body.chomp : nil

      return handle_response(response.code.to_i, body)
    end

    def send_async
      http = @client.sync_http_client
      http.request_async(@verb, @uri, @params, @body, @head)
    end

    private

    def handle_response(status_code, body)
      case status_code
        when 200
          return symbolize_first_level(MultiJson.decode(body))
        when 202
          return true
        when 400
          raise Error, "Bad request: #{body}"
        when 401
          raise AuthenticationError, body
        when 404
          raise Error, "404 Not found (#{@uri.path})"
        when 407
          raise Error, "Proxy Authentication Required"
        else
          raise Error, "Unknown error (status code #{status_code}): #{body}"
      end
    end

    def symbolize_first_level(hash)
      hash.inject({}) do |result, (key, value)|
        result[key.to_sym] = value
        result
      end
    end
  end
end