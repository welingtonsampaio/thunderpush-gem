begin
  require 'bundler/setup'
rescue LoadError
  puts 'although not required, it is recommended that you use bundler when running the tests'
end

require File.expand_path( '../../lib/thunderpush', __FILE__ )
require 'rspec'
require 'em-http' # As of webmock 1.4.0, em-http must be loaded first
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!
  end
end