# ThunderPush - Beta

Gerenciamento e API para comunicação com o servidor de eventos [ThunderPush](https://github.com/thunderpush/thunderpush).

## Installation

Add this line to your application's Gemfile:

    gem 'thunderpush', github: 'welingtonsampaio/thunderpush-gem'

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
 - Sets whether the request should be encrypted using SSL. If set to true modifies the scheme for `https` and the door to `443`, if you need to change the default setting after you configure it. E.g.:
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

## Contributing

1. Fork it ( https://github.com/welingtonsampaio/thunderpush-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
