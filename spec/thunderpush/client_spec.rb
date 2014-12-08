require 'spec_helper'

describe ThunderPush::Client do

  before do
    @client1 = ThunderPush::Client.new

    @client2 = ThunderPush::Client.new
    @client2.publickey = 'publickey'
    @client2.privatekey = 'privatekey'
    @client2.hostname = 'localhost'
    @client2.scheme = 'https'
    @client2.port = 1123
  end

  it 'should return the url without public and private key informations' do
    @client1.url = 'http://public:private@127.0.0.1:5678'
    expect(@client1.url.to_s).to eq 'http://127.0.0.1:5678/api/1.0.0/'
  end

  it 'should return net/http object from sync_http_client' do
    expect(@client1.sync_http_client).to be_kind_of HTTPClient
  end

  it 'should be able configure from config and block' do
    expect { @client1.config }.to raise_error ThunderPush::ConfigurationError
    old_port = @client1.port
    @client1.config do |config|
      config.port = 111
    end
    expect(@client1.port).not_to eq old_port
  end

  describe 'different instances' do
    it 'should send scheme messages to different objects' do
      expect(@client1.scheme).not_to eq @client2.scheme
    end

    it 'should send publickey messages to different objects' do
      expect(@client1.publickey).not_to eq @client2.publickey
    end

    it 'should send privatekey messages to different objects' do
      expect(@client1.privatekey).not_to eq @client2.privatekey
    end

    it 'should send hostname messages to different objects' do
      expect(@client1.hostname).not_to eq @client2.hostname
    end

    it 'should send port messages to different objects' do
      expect(@client1.port).not_to eq @client2.port
    end

    it 'should send encrypted messages to different objects' do
      @client1.encrypted = false
      @client2.encrypted = true
      expect(@client1.scheme).not_to eq @client2.scheme
      expect(@client1.port).not_to eq @client2.port
    end
  end

  describe 'default configuration' do
    it 'should be preconfigured for api host' do
      expect(@client1.hostname).to eq '127.0.0.1'
    end

    it 'should be preconfigured for port 80' do
      expect(@client1.port).to eq 5678
    end

    it 'should use standard logger if no other logger if defined' do
      ThunderPush.logger.debug('foo')
      expect(ThunderPush.logger).to be_kind_of(Logger)
    end
  end

  describe 'logging configuration' do
    it "can be configured to use any logger" do
      logger = double("ALogger")
      expect(logger).to receive(:debug).with('foo')
      ThunderPush.logger = logger
      ThunderPush.logger.debug('foo')
      ThunderPush.logger = nil
    end
  end

  describe 'configuration using url' do
    it 'should be possible to configure everything by setting the url' do
      @client1.url = 'http://public:private@127.0.0.1:5678'

      expect(@client1.scheme).to eq 'http'
      expect(@client1.publickey).to eq 'public'
      expect(@client1.privatekey).to eq 'private'
      expect(@client1.hostname).to eq '127.0.0.1'
      expect(@client1.port).to eq 5678
    end

    it 'should override scheme and port when setting encrypted=true after url' do
      @client1.url = 'http://secret@127.0.0.1:5678'
      @client1.encrypted = true

      expect(@client1.scheme).to eq 'https'
      expect(@client1.port).to eq 443
    end

    it "should fail on bad urls" do
      expect { @client1.url = "gopher/somekey:somesecret@://127.0.0.1://m:8080" }.to raise_error
    end
  end

  describe 'trigger events do server' do

    it 'should be able trigger a event to ThunderPush server' do
      @client1.authenticate 'apikey', 'apisecret'
      api_path = %r{/apikey/events/event-name/}
      stub_request(:post, api_path).
      with({
              :headers => { 'X-Thunder-Secret-Key' => 'apisecret' }
          }).
      to_return({
        :status => 202
      })
      @client1.trigger ['channel-name'], 'event-name', {data: 'content'}
    end

  end

  describe 'Private commands' do

    it 'should de able add a new user in private channel' do
      @client1.authenticate 'apikey', 'apisecret'
      api_path = %r{/apikey/private/channels/private-channel/}
      stub_request(:post, api_path).
        with({
               :headers => { 'X-Thunder-Secret-Key' => 'apisecret' },
               :body => 'userid'
             }).
        to_return({
                    :status => 200,
                    :body => MultiJson.encode({users: 1})
                  })
      @client1.private_subscribe_sync 'userid', 'private-channel'
      @client1.private_subscribe_async 'userid', 'private-channel'
    end

  end

end