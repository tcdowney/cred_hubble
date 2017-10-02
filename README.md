# CredHubble :full_moon_with_face::telescope::full_moon_with_face:

Unofficial and **incomplete** Ruby client for storing and fetching credentials from a [Cloud Foundry CredHub](https://github.com/cloudfoundry-incubator/credhub) credential storage service.

It only supports the unauthenticated `/info` and `/health` endpoints for now, but eventually this library will let your Ruby app fetch secrets (e.g. database creds, Rails session secrets, AWS access keys, etc.) from CredHub at runtime, meaning you'll no longer need to store them in plaintext config files or in your app's environment.

That's the dream at least.

Right now this is just something I'm working on for fun since it's been a while since I've gotten to write a Ruby HTTP client. :grin:

## Installation

Add this line to your application's Gemfile:
There is a very very alpha release available on Ruby Gems, but it only supports the unauthenticated endpoints. A new release won't be published until I'm satisfied with the completeness of this library.

```ruby
gem 'cred_hubble', git: 'https://github.com/tcdowney/cred_hubble'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cred_hubble

## Usage

This gem currently supports the following CredHub endpoints:

* `/info`
* `/health`
* `/api/v1/data/<credential-id>`

To try out the unauthenticated `info` and `health` endpoints, just do the following in your favorite Ruby console:

```ruby
> credhub_url = 'https://credhub.your-cloud-foundry.com:8844'
> credhub_client = CredHubble::Client.new(credhub_url: credhub_url)
> info = credhub_client.info
  => #<CredHubble::Resources::Info:0x00007fb36497a490 ...
> info.auth_server.url
  => "https://uaa.service.cf.internal:8443"
> health = credhub_client.health
  => #<CredHubble::Resources::Health:0x00007fb3648f0218 ...
> health.status
  => "UP"
```

To call endpoints that require authentication, you can authenticate with either an oAuth2 bearer token auth header or using mutual TLS (mTLS).
Here are some examples:

### Authenticating with an oAuth2 header
```ruby
> credhub_url    = 'https://credhub.your-cloud-foundry.com:8844'
> auth_header    = 'eyJhbGc.....OiJSUzI1NiIsI' # omit any 'bearer' portion
> credhub_client = CredHubble::Client.new_from_token_auth(
                     credhub_url: credhub_url,
                     auth_header_token: auth_header
                   )
> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

### Authenticating with a client cert and key over mutual TLS
A typical Cloud Foundry application using CredHub will have access to two environment variables that contain these paths:
* `ENV['CF_INSTANCE_CERT']`
* `ENV['CF_INSTANCE_KEY']`

CredHub's CA certificate should already have been placed in the app instance's trusted cert store by Diego.

```ruby
> credhub_url      = 'https://credhub.your-cloud-foundry.com:8844'
> client_cert_path = '/etc/cf-instance-credentials/instance.crt' # ENV['CF_INSTANCE_CERT']
> client_key_path  = '/etc/cf-instance-credentials/instance.key' # ENV['CF_INSTANCE_KEY']
> credhub_client   = CredHubble::Client.new_from_mtls_auth(
                       credhub_url: credhub_url,
                       client_cert_path: client_cert_path,
                       client_key_path: client_key_path
                     )
           
> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

### Specifying the CredHub CA certificate
If your CredHub server is using a self-signed (or otherwise non-trusted by your system) certificate you can supply CredHubble with the path to a local copy of the signing CA certificate.

```ruby
> credhub_url     = 'https://credhub.your-cloud-foundry.com:8844'
> auth_header     = 'eyJhbGc.....OiJSUzI1NiIsI' # omit any 'bearer' portion
> credhub_ca_path = '/some/path/certs/credhub_ca.crt'
> credhub_client  = CredHubble::Client.new_from_token_auth(
                      credhub_url: credhub_url,
                      auth_header_token: auth_header,
                      credhub_ca_path: credhub_ca_path
                    )

> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tcdowney/cred_hubble.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
