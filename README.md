# CredHubble :full_moon_with_face::telescope::full_moon_with_face:

[![Gem Version](https://badge.fury.io/rb/cred_hubble.svg)](https://badge.fury.io/rb/cred_hubble) [![Build Status](https://travis-ci.org/tcdowney/cred_hubble.svg?branch=master)](https://travis-ci.org/tcdowney/cred_hubble)

Unofficial Ruby client for storing and fetching credentials from a [Cloud Foundry CredHub](https://github.com/cloudfoundry-incubator/credhub) credential store.
The goal of this gem is to make it easier for Ruby apps (Rails, Sinatra, etc.) deployed on Cloud Foundry to store and retrieve secrets (e.g. Rails session_token_base, database credentials, AWS keys, etc.).
For a more concrete example of usage, I've written a blog post on how one might [use CredHubble with a Rails app](https://downey.io/blog/securing-rails-credentials-cloud-foundry-credhub/).

CredHubble is just something I work on in my spare time for fun and is not feature-complete, but it should get the job mostly done.
If you do end up using it and find any bugs or would like to see more functionality, feel free to [submit a PR](https://github.com/tcdowney/cred_hubble/pulls) or [log an issue](https://github.com/tcdowney/cred_hubble/issues).

View the [usage](#usage) section to see what CredHub endpoints the gem currently supports.

## Installation

To install the latest release, add this line to your application's Gemfile:
```ruby
gem 'cred_hubble', '~> 0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cred_hubble
    
## Usage

CredHubble currently supports the following [CredHub endpoints](https://credhub-api.cfapps.io):

* **[Client Creation and Authentication](#client-creation-and-authentication)**


* **[GET Info](#get-info-and-get-health):** `/info`
* **[GET Health](#get-info-and-get-health):** `/health`


* **[GET Credential by ID](#get-credential-by-id):** `/api/v1/data/<credential-id>`
* **[GET Credentials by Name](#get-credentials-by-name):** `/api/v1/data?name=<credential-name>`
* **[PUT Credential](#put-credential):** `/api/v1/data`
* **[DELETE Credential by Name](#delete-credential-by-name):** `/api/v1/data`
* **[POST Interpolate Credentials](#post-interpolate-credentials):** `/api/v1/interpolate`


* **[GET Permissions by Credential Name](#get-permissions-by-credential-name):** `/api/v1/permissions?credential_name=<credential-name>`
* **[POST Add Permissions](#post-add-permissions):** `/api/v1/permissions`
* **[DELETE Delete Permissions](#delete-delete-permissions):** `/api/v1/permissions?credential_name=<credential-name>&actor=<actor>`

### Client Creation and Authentication

To call endpoints that require authentication, you will need to authenticate with either an oAuth2 bearer token 'Authorization' header or with certificate-based [mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication) (mTLS).
Here are some examples:

#### Authenticating with an oAuth2 header
```ruby
> auth_header    = 'eyJhbGc.....OiJSUzI1NiIsI' # omit any 'bearer' portion
> credhub_client = CredHubble::Client.new_from_token_auth(
                     host: 'credhub.your-cloud-foundry.com',
                     port: '8844',
                     auth_header_token: auth_header
                   )
           
> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

#### Authenticating with a client cert and key over mutual TLS
A typical Cloud Foundry application using CredHub will have access to two environment variables that contain these paths:
* `ENV['CF_INSTANCE_CERT']`
* `ENV['CF_INSTANCE_KEY']`

CredHub's CA certificate should already have been placed in the app instance's trusted cert store by Diego.

```ruby
> client_cert_path = '/etc/cf-instance-credentials/instance.crt' # ENV['CF_INSTANCE_CERT']
> client_key_path  = '/etc/cf-instance-credentials/instance.key' # ENV['CF_INSTANCE_KEY']
> credhub_client   = CredHubble::Client.new_from_mtls_auth(
                       host: 'credhub.your-cloud-foundry.com',
                       port: '8844',
                       client_cert_path: client_cert_path,
                       client_key_path: client_key_path
                     )
           
> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

#### Specifying the CredHub CA certificate
If your CredHub server is using a self-signed (or otherwise non-trusted by your system) certificate you can supply CredHubble with the path to a local copy of the signing CA certificate.

```ruby
> auth_header     = 'eyJhbGc.....OiJSUzI1NiIsI' # omit any 'bearer' portion
> credhub_ca_path = '/some/path/certs/credhub_ca.crt'
> credhub_client  = CredHubble::Client.new_from_token_auth(
                      host: 'credhub.your-cloud-foundry.com',
                      port: '8844',
                      auth_header_token: auth_header,
                      ca_path: credhub_ca_path
                    )

> credential = credhub_client.credential_by_id('f8d5a201-c3b9-48ae-8bc4-3b86b42210a1')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

### Supported Actions

### GET Info and GET Health
To try out the unauthenticated `info` and `health` endpoints, just do the following in your Ruby console:

```ruby
> credhub_client = CredHubble::Client.new(host: 'credhub.your-cloud-foundry.com', port: '8844')
           
> info = credhub_client.info
  => #<CredHubble::Resources::Info:0x00007fb36497a490 ...
  
> info.auth_server.url
  => "https://uaa.service.cf.internal:8443"
  
> health = credhub_client.health
  => #<CredHubble::Resources::Health:0x00007fb3648f0218 ...
  
> health.status
  => "UP"
```

For accessing endpoints that require authentication, simply create an authenticated client using one of the [authentication methods above](#authentication).

### GET Credential by ID
The `credential_by_id` method retrieves a single Credential resource from CredHub by ID.

```ruby
> credhub_client.credential_by_id('f297f736-dad2-4450-a7da-d3ff99f2030d')
  => #<CredHubble::Resources::ValueCredential:0x0055f3811a5958 ...
```

### GET Credentials by Name
Retrieves a collection of Credentials from CredHub for the given name. The `credentials_by_name` method will return all stored versions of the credential by default.
You can retrieve only the most recent version of the credential using the `current` option, or specify the number of versions to fetch with the `versions` option.

```ruby
> credentials = credhub_client.credentials_by_name('/admin-user-password')
  => #<CredHubble::Resources::CredentialCollection:0x00007f @data=[#<CredHubble::Resources::PasswordCredential:0x00004a ...
> credentials.count
  => 3
> credentials.map(&:id)
  => ["5298e0e4-c3f5-4c73-a156-9ffce4c137f5", "6980ec59-c7e6-449a-b525-298648cfe6a7", "3e709d6e-585c-4526-ac0d-fe99316f2255"]
  
> credentials = credhub_client.credentials_by_name('/admin-user-password', versions: 2)  
> credentials.count
  => 2
> credentials.map(&:id)
  => ["5298e0e4-c3f5-4c73-a156-9ffce4c137f5", "6980ec59-c7e6-449a-b525-298648cfe6a7"]
  
> credentials = credhub_client.credentials_by_name('/admin-user-password', current: true)
  => #<CredHubble::Resources::CredentialCollection:0x00007f @data=[#<CredHubble::Resources::PasswordCredential:0x00004a ...
> credentials.count
  => 1
> credentials.map(&:id)
  => ["5298e0e4-c3f5-4c73-a156-9ffce4c137f5"]
```

Most times, though, you'll just want to grab the value of the most current version of a credential. This is where the `current_credential_value` method comes in.
Here's what that might look like for the example above:

```ruby
> credhub_client.current_credential_value('/admin-user-password')
  => "8mn6LSLzJqhVxnqYCCXUxUADdj8XneYP"
```

### PUT Credential
You can create new Credentials using the `put_credential` method. If you wish to replace an already existing Credential, simply pass
`overwrite: true` to the method and CredHub will create a new version of the Credential. Previous versions can be retrieved by using
the `credentials_by_name` method.

```ruby
> credential = CredHubble::Resources::UserCredential.new(
                    name: '/foundry-fred-user',
                    value: {username: 'foundy_fred', password: 's3cr3t'}
               )   
  => #<CredHubble::Resources::UserCredential:0x00007fb322caf3f0 @name="/foundry-fred-user", @value=#<CredHubble::Resources::UserValue ...
  
> credhub_client.put_credential(credential)
  => #<CredHubble::Resources::UserCredential:0x00007fb322d676d0
        @name="/foundry-fred-user",
        @value=#<CredHubble::Resources::UserValue:0x00007fb322d67478
                  @username="foundy_fred",
                  @password="s3cr3t",
                  @password_hash="$6$WwMLCRDr$Br54U0EnWD.A5i1EV9Cc7P16ZdjIBk0fFiYKghfOjW1MvL.vaXhWua.eGIbe0ziQIEP4s2OcGQpEEsc9ClFuA0">,
                  @id="92775889-71e0-41d1-a44c-93eb8fc5161a",
                  @type="user",
                  @version_created_at="2017-10-06T05:10:57Z">
             
> credential.value.password = 'foo bar'
  => "foo bar"
  
> credhub_client.put_credential(credential, overwrite: true)
  => #<CredHubble::Resources::UserCredential:0x00007fb322d676d0
        @name="/foundry-fred-user",
        @value=#<CredHubble::Resources::UserValue:0x00007fb322d67478
                  @username="foundy_fred",
                  @password="foo bar",
                  @password_hash="$6$WNAIgDrf$/.DxIfIg.8W6ZaIRjrjlOWS8FenigeWtswWr/D9edMbmSReYCzgG6VVdcdaftenq5VED3C8MJNVtDnNLF86SD.">,
                  @id="292ae24c-d7a3-4d8b-86a2-43630b83bafb",
                  @type="user",
                  @version_created_at="2017-10-06T05:11:43Z">
````

By default, only the creator of a Credential has access to read, write, delete, view its ACL, or updates its ACL. If you wish to
grant other parties various permissions for a given Credential, the `put_credential` method takes an optional `additional_permissions` array.

```ruby
> credential = CredHubble::Resources::UserCredential.new(
                    name: '/foundry-fred-user',
                    value: {username: 'foundy_fred', password: 's3cr3t'}
               )   
  => #<CredHubble::Resources::UserCredential:0x00007fb322caf3f0 @name="/foundry-fred-user", @value=#<CredHubble::Resources::UserValue ...
  
> permission = CredHubble::Resources::Permission.new(
                 actor: 'uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47',
                 operations: ['write', 'read']
               )
  => #<CredHubble::Resources::Permission:0x00007f @actor="uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47", @operations=["write", "read"]>
  
> credhub_client.put_credential(credential, additional_permissions: [permission])
  => #<CredHubble::Resources::UserCredential:0x00007fb322d676d0 ...
````

### DELETE Credential by Name
The `delete_credential_by_name` method allows you to delete all versions of a Credential for the given name.

```ruby
> credentials = credhub_client.credentials_by_name('/admin-user-password')
  => #<CredHubble::Resources::CredentialCollection:0x00007f @data=[#<CredHubble::Resources::PasswordCredential:0x00004a ...
> credentials.count
  => 3
  
> credhub_client.delete_credential_by_name('/admin-user-password')  
  => true
> credhub_client.credentials_by_name('/admin-user-password')
  => CredHubble::Http::NotFoundError: status: 404, body: {"error":"The request could not be completed ...
````

### POST Interpolate Credentials
Cloud Foundry applications traditionally access the credentials for any bound service instances through a `VCAP_SERVICES` environment variable.
Nowadays, however, some Service Brokers are CredHub aware and may choose to store service instance credentials in CredHub.
Apps bound to said services would only see `"credhub-ref"` key in place of actual credentials for that service instance. Here's an example `VCAP_SERVICES`:

```json
{
  "grid-config":[
    {
      "credentials":{
        "credhub-ref":"/grid-config/users/kflynn"
      },
      "label":"grid-config",
      "name":"config-server",
      "plan":"digital-frontier",
      "provider":null,
      "syslog_drain_url":null,
      "tags":[
        "configuration",
        "biodigital-jazz"
      ],
      "volume_mounts":[]
    }
  ],
  "encomSQL":[
    {
      "credentials":{
        "credhub-ref":"/encomSQL/db/users/63f7b900-982f-4f20-9213-6d270c3c58ea"
      },
        "label":"encom-db",
      "name":"encom-enterprise-db",
      "plan":"enterprise",
      "provider":null,
      "syslog_drain_url":null,
      "tags":[
        "database",
        "sql"
      ],
      "volume_mounts":[]
    }
  ]
}
```

Fortunately, CredHub supports an "interpolate" endpoint which allows an app to populate these values wholesale.
Here's how a CF application might use CredHubble's `interpolate_credentials` method to do that via mTLS authentication:

```ruby
> client_cert_path = ENV['CF_INSTANCE_CERT']
> client_key_path  = ENV['CF_INSTANCE_KEY']
> credhub_client   = CredHubble::Client.new_from_mtls_auth(
                       host: 'credhub.your-cloud-foundry.com',
                       port: '8844',
                       client_cert_path: client_cert_path,
                       client_key_path: client_key_path
                     )
           
> interpolated_services_json = credhub_client.interpolate_credentials(ENV['VCAP_SERVICES'])
  => '{
       "grid-config":[
         {
           "credentials":{
             "username":"kflynn",
             "password":"FlynnLives"
           },
           "label":"grid-config",
           "name":"config-server",
           "plan":"digital-frontier",
           "provider":null,
           "syslog_drain_url":null,
           "tags":[
             "configuration",
             "biodigital-jazz"
           ],
           "volume_mounts":[]
         }
       ],
       "encomSQL":[
         {
           "credentials":{
             "username":"grid-db-user",
             "password":"p4ssw0rd"
           },
           ... abridged ...
         }
       ]
     }'
```

### GET Permissions by Credential Name

You can use the `permissions_by_credential_name` method to view the list of permissions for a given Credential.

```ruby
> credhub_client.permissions_by_credential_name('/credential-name')
  => #<CredHubble::Resources::PermissionCollection:0x00007fa231c12020
        @credential_name="/credential-name",
        @permissions=[
          #<CredHubble::Resources::Permission:0x00007fa231c11f08
              @actor="uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47",
              @operations=["read", "write", "delete"]>,
          #<CredHubble::Resources::Permission:0x00007fa231c11e18
              @actor="mtls-app:18f64563-bcfe-4c88-bf73-05c9ad3654c8",
              @operations=["read"]>,
          #<CredHubble::Resources::Permission:0x00007fa231c11d00
              @actor="uaa-client:some_uaa_client",
              @operations=["read", "write", "delete", "read_acl", "write_acl"]>
        ]>
```

### POST Add Permissions

You can use the `add_permissions` method to add additional permissions to an existing Credential.

```ruby
> credhub_client.permissions_by_credential_name('/my-awesome-credential').count
  => 2
  
> new_permission = CredHubble::Resources::Permission.new(actor: 'uaa-user:b2449249', operations: ['read'])
> new_permission_collection = CredHubble::Resources::PermissionCollection.new(
                                credential_name: '/my-awesome-credential',
                                permissions: [new_permission]
                              )
                       
> credhub_client.add_permissions(new_permission_collection)
  => #<CredHubble::Resources::PermissionCollection:0x00007fa231c12020
        @credential_name="/my-awesome-credential",
        @permissions=[
          #<CredHubble::Resources::Permission:0x00007fa231c11f08
              @actor="uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47",
              @operations=["read", "write", "delete"]>,
          #<CredHubble::Resources::Permission:0x00007fa231c11e18
              @actor="mtls-app:18f64563-bcfe-4c88-bf73-05c9ad3654c8",
              @operations=["read"]>,
          #<CredHubble::Resources::Permission:0x00007fa231c11d00
              @actor="uaa-user:b2449249",
              @operations=["read"]>
        ]>
        
> credhub_client.permissions_by_credential_name('/my-awesome-credential').count
  => 3
```

### DELETE Delete Permissions

You can remove any permissions for a given actor from a credential with the `delete_permissions` method which takes a `credential_name` and `actor`.

```ruby
> credhub_client.permissions_by_credential_name('/my-awesome-credential').count
  => 3
  
> credhub_client.delete_permissions('/my-awesome-credential', 'uaa-user:b2449249')
  => true
        
> credhub_client.permissions_by_credential_name('/my-awesome-credential').count
  => 2
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tcdowney/cred_hubble.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
