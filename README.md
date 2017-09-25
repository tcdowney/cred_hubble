# CredHubble :telescope: :full_moon_with_face:

Unofficial and **incomplete** Ruby client for storing and fetching credentials from a [Cloud Foundry CredHub](https://github.com/cloudfoundry-incubator/credhub) credential storage service.

It only supports the unauthenticated `/info` and `/health` endpoints for now, but eventually this library will let your Ruby app fetch secrets (e.g. database creds, Rails session secrets, AWS access keys, etc.) from CredHub at runtime, meaning you'll no longer need to store them in plaintext config files or in your app's environment.

That's the dream at least.

Right now this is just something I'm working on for fun since it's been a while since I've gotten to write a Ruby HTTP client. :grin:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cred_hubble'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cred_hubble

## Usage

This gem currently only support the CredHub endpoints that allow unauthenticated access:

* `/info`
* `/health`

To try out these endpoints, just do the following in your favorite Ruby console:

```ruby
> credhub_url = 'https://credhub.your-cloud-foundry.com:8844'
> credhub_client = CredHubble::Client.new(credhub_url)
> info = credhub_client.info
  => #<CredHubble::Resources::Info:0x00007fb36497a490 ...
> info.auth_server.url
  => "https://uaa.service.cf.internal:8443"
> health = credhub_client.health
  => #<CredHubble::Resources::Health:0x00007fb3648f0218 ...
> health.status
  => "UP"
```

A future update to the gem will allow you hit authenticated endpoints using either a UAA token or mutual TLS for authentication.

This is still very much a work in progress.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tcdowney/cred_hubble.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
