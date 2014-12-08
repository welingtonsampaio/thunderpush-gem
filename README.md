# ThunderPush - Beta

Management and API to communicate with the event server [ThunderPush](https://github.com/thunderpush/thunderpush).

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'thunderpush', github: 'welingtonsampaio/thunderpush-gem'
```

And then execute:

    $ bundle install


## Configuration

The mode of use was based on the API Http service.

### Rails
Create a initializer file in `config/initializers/thunderpush.rb`
```ruby
ThunderPush.default_client.config do |config|
	config.hostname= 'localhost'
	config.port= 7171
	config.authenticate 'key', 'secret'
	
	# or inline configuration
	
	config.url= 'http://key:secret@localhost:7171'
end
```

### Parameters
- **scheme** - `String`
 - Defines the type of request, with the options `http` or `https`
  ```ruby
  config.scheme = 'https'
  ```
- **hostname** - `String`
 - Binds server to custom address where will be executed the request. Default `127.0.0.1`
  ```ruby
  config.hostname = 'hostname'
  ```
- **port** - `Integer`
 - Binds server to custom port where will be executed the request. Default `5678`
  ```ruby
  config.port = 80
  ```
- **publickey** - `String` required
 - Client key to connection authentication
  ```ruby
  config.publickey = 'key'
  ```
- **privatekey** - `String` required
 - Server Api Key to connection authentication
  ```ruby
  config.privatekey = 'long-hash-key'
  ```
- **encrypted** - `Boolean`
 - Sets whether the request should be encrypted using SSL. If set to true modifies the scheme for `https` and the door 
 to `443`, if you need to change the default setting after you configure it. E.g.:
  ```ruby
  config.encrypted = true # scheme=>'https' and port=>443
  config.port = 10001 # changed port after encrypted request
  ```

### Methods
- **authenticate** -> `key:String`, `secret:String`
 - Adds the publickey and privatekey in only one method.
 ```ruby
 config.authenticate 'key', 'long-hash-key'
 ```
- **url=** -> `uri:String`
 - Parser URI to configuration inline method. E.g.:
 ```ruby
 config.url = 'https://key:long-hash-key@localhost:10001'
 # returns:
 #   scheme => 'https'
 #   hostname => 'localhost'
 #   port => 10001
 #   publickey => 'key'
 #   privatekey => 'long-hash-key'
 ```

## Usage

The use of the API was divided into three modules. They are: _client_, _channel_ and _user_. Each is responsible for 
certain tasks. Below I am listing the usage of each module.


### Clients (ThunderPush::Client)

Client is the library that performs the call to the server events. It is possible to have more than one instance with 
different settings for each, or use the default_client implemented within the module. For using the standard object use
the following syntax:
```ruby
ThunderPush.default_client
```

To create a new instance, use the following command:
```ruby
client = ThunderPush::Client.new { :publickey => 'key', :privatekey => 'long-hash-key' }
```

Some methods commonly used in client delegated to the main module, these methods use the standard instance of the Client. E.g.:
```ruby
ThunderPush.trigger 'my-channel', 'my-event', {foo: 'bar'}
```
The methods that are in the delegate are: `trigger`, `trigger_async`, `post`, `post_async`, `get` and `get_async`

#### Trigger (ThunderPush::Client)

Performs the event requests. The event requests are identical to a POST request to a channel, with the difference of the
structure to the event. Need a channel and event for the execution to be triggered.

**Options:**

- **channel** - `String` - Channel name that will receive the event
- **event_name** - `String` - Event name to be triggered
- **data** - `Hash` - Content to be sent to the event

**Publishing events**

```ruby
ThunderPush.trigger 'my-channel', 'my-event', {foo: 'bar'}
ThunderPush.trigger_async 'my-channel', 'my-event', {foo: 'bar'} # not waiting server response
```

#### Generic requests to the ThunderPush HTTP API (ThunderPush::Client)

Using the GET and POST methods can run on ThunderPush HTTP API directly and create their own forms of request. Below show how to run and the content of each request.

**Post** and **PostAsync**:

Options: `path:String` e `body:String`. Path, contains the relative path to version api ThunderPush, eg: `/key/channels/channel-name/`. Body, contains the contents of the request to be sent, it must contain the `json` format, eg: `'{"foo":"bar"}'`.

Tip: encode a hash in string!

```ruby
ThunderPush.post "/key/channels/my-channel/", {foo: "bar"}.to_json
ThunderPush.post_async "/key/channels/my-channel/", {foo: "bar"}.to_json

# POST http://127.0.0.1:5678/api/1.0.0/key/channels/channel-name/
# BODY {"foo":"bar"}
```

**Get** and **GetAsync**:

Options: `path:String` e `params:Hash`. Path, contains the relative path to version api ThunderPush, eg: `/key/users/[user_id]/`. Body, contains the contents of the request to be sent, it must contain the `json` format, eg: `{foo: "bar"}`.

Tip: encode a hash in string!

```ruby
ThunderPush.get "/key/users/[user_id]/", {foo: "bar"}
ThunderPush.get_async "/key/users/[user_id]/", {foo: "bar"}

# GET http://127.0.0.1:5678/api/1.0.0/key/users/[user_id]/?foo=bar
```

### Channels

`TODO: not implemented`

### Users

`TODO: not implemented`

## Contributing

1. Fork it ( https://github.com/welingtonsampaio/thunderpush-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
