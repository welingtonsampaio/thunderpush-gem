require 'spec_helper'

describe ThunderPush::Request do
  before do
    @client = ThunderPush.default_client
    @client.authenticate 'key', 'secret'
  end

  describe 'parameters in initializer' do
    it 'should give error when client parameter is not ThunderPush::Client' do
      expect { ThunderPush::Request.new(@client, 'GET', @client.url, {}) }.not_to raise_error
      expect { ThunderPush::Request.new('client', 'GET', @client.url, {}) }.to raise_error(ThunderPush::ConfigurationError)
    end

    it 'should receive GET or POST parameter in the verb' do
      expect { ThunderPush::Request.new(@client, 'GET', @client.url, {}) }.not_to raise_error
      expect { ThunderPush::Request.new(@client, 'POST', @client.url, {}) }.not_to raise_error
      expect { ThunderPush::Request.new(@client, 'PATH', @client.url, {}) }.to raise_error(ThunderPush::ConfigurationError)
    end

    it 'should give error when uri parameter is not URI' do
      expect { ThunderPush::Request.new(@client, 'GET', @client.url, {}) }.not_to raise_error
      expect { ThunderPush::Request.new(@client, 'GET', '', {}) }.to raise_error(ThunderPush::ConfigurationError)
    end

  end

  describe 'verbs request' do
    it 'should be able to send a GET request' do
      api_path = %r{/key/channels/channel-name/}
      stub_request(:get, api_path).
        with({
               :headers => {'X-Thunder-Secret-Key' => 'secret'},
               :query => hash_including({'auth_key'=>'key'})
             }).
        to_return(:status => 202)
      ThunderPush::Request.new(@client, 'GET', @client.url('key/channels/channel-name/'), {}).send_sync
    end

    it 'should be able to send a POST request' do
      api_path = %r{/key/channels/channel-name/}
      stub_request(:post, api_path).
        with({
               :headers => {'X-Thunder-Secret-Key' => 'secret'},
               :body => {foo: 'bar'}
             }).
        to_return(:status => 202)
      ThunderPush::Request.new(@client, 'POST', @client.url('key/channels/channel-name/'), {}, MultiJson.encode({foo: 'bar'})).send_sync
    end
  end

end