autoload 'Logger', 'logger'
require 'active_support/all'

module ThunderPush
  # All errors descend from this class so they can be easily rescued
  #
  # @example
  #   begin
  #     ThunderPush.trigger('channel_name', 'event_name, {:some => 'data'})
  #   rescue ThunderPush::Error => e
  #     # Do something on error
  #   end
  class Error < RuntimeError; end
  class AuthenticationError < Error; end
  class ConfigurationError < Error; end
  class HTTPError < Error; end

  API_VERSION = '1.0.0'

  autoload :Client,  'thunderpush/client'
  autoload :Request, 'thunderpush/request'
  autoload :Resource, 'thunderpush/resource'

  class << self
    attr_writer :logger
    def logger
      @logger ||= begin
        log = Logger.new($stdout)
        log.level = Logger::INFO
        log
      end
    end

    def default_client
      @default_client ||= ThunderPush::Client.new
    end
    %w[trigger trigger_async post post_async get get_async].
      each { |method| delegate method, to: 'default_client' }

  end
end

require 'thunderpush/version'