require 'addressable'
require 'cred_hubble/resources/resources'
require 'cred_hubble/http/client'
require 'openssl'

# rubocop:disable ClassLength
module CredHubble
  class Client
    # Instantiates a new CredHubble::Client.
    #
    # @param host [String] host for the target CredHub server
    # @param port [Integer] port for the target CredHub server
    # @param auth_header_token [String] oAuth2 bearer token for auth header
    # @param client_cert_path [String] path to a client TLS certificate
    # @param client_key_path [String] path to a client TLS encryption key
    # @param ca_path [String] path to a CA certificate
    # @return [CredHubble::Client] a CredHubble::Client instance
    def initialize(host:, port: 8844, auth_header_token: nil, ca_path: nil,
                   client_cert_path: nil, client_key_path: nil)

      @host = host
      @port = port
      @auth_header_token = auth_header_token
      @ca_path = ca_path
      @client_cert_path = client_cert_path
      @client_key_path = client_key_path
    end

    # Instantiates a new CredHubble::Client using an oAuth2 bearer token for auth header authentication.
    #
    # @param host [String] host for the target CredHub server
    # @param port [Integer] port for the target CredHub server
    # @param auth_header_token [String] oAuth2 bearer token for auth header
    # @param ca_path [String] path to a CA certificate
    # @return [CredHubble::Client] a CredHubble::Client instance
    def self.new_from_token_auth(host:, port: 8844, auth_header_token:, ca_path: nil)
      new(
        auth_header_token: auth_header_token,
        ca_path: ca_path,
        host: host,
        port: port
      )
    end

    # Instantiates a new CredHubble::Client using a client TLS certificate and key for mutual TLS authentication.
    #
    # @param host [String] host for the target CredHub server
    # @param port [Integer] port for the target CredHub server
    # @param client_cert_path [String] path to a client TLS certificate
    # @param client_key_path [String] path to a client TLS encryption key
    # @param ca_path [String] path to a CA certificate
    # @return [CredHubble::Client] a CredHubble::Client instance
    def self.new_from_mtls_auth(host:, port: 8844, client_cert_path:, client_key_path:, ca_path: nil)
      new(
        client_cert_path: client_cert_path,
        client_key_path: client_key_path,
        host: host,
        ca_path: ca_path,
        port: port
      )
    end

    # Performs a GET request to the CredHub /info endpoint.
    #
    # @return [CredHubble::Resources::Info] a CredHubble::Resources::Info instance
    def info
      response = http_client.get('/info').body
      CredHubble::Resources::Info.from_json(response)
    end

    # Performs a GET request to the CredHub /health endpoint.
    #
    # @return [CredHubble::Resources::Health] a CredHubble::Resources::Health instance
    def health
      response = http_client.get('/health').body
      CredHubble::Resources::Health.from_json(response)
    end

    # Performs a GET request to the CredHub /key-usage endpoint.
    #
    # @return [CredHubble::Resources::KeyUsage] a CredHubble::Resources::KeyUsage instance
    def key_usage
      response = http_client.get('api/v1/key-usage').body
      CredHubble::Resources::KeyUsage.from_json(response)
    end

    # Retrieves a Credential by ID.
    #
    # @param credential_id [String] a CredHub credential identifier
    # @return [CredHubble::Resources::Credential] a CredHubble::Resources::Credential instance,
    #   e.g. CredHubble::Resources::ValueCredential
    def credential_by_id(credential_id)
      response = http_client.get("/api/v1/data/#{credential_id}").body
      CredHubble::Resources::CredentialFactory.from_json(response)
    end

    # Retrieves a collection of Credentials by Name.
    #
    # @param name [String] a CredHub credential name, e.g '/my-credential'
    # @param current [Boolean] whether or not to return only the current version of a Credential
    # @param versions [Integer] the maximum number of versions of a Credential to return
    # @return [CredHubble::Resources::CredentialCollection] a CredHubble::Resources::CredentialCollection instance,
    #   containing an enumerable list of Credentials
    def credentials_by_name(name, current: nil, versions: nil)
      template = Addressable::Template.new('/api/v1/data{?query*}')

      query_args = { name: name, current: current, versions: versions }.reject { |_, v| v.nil? }
      path = template.expand(query: query_args).to_s

      response = http_client.get(path).body
      CredHubble::Resources::CredentialCollection.from_json(response)
    end

    # Retrieves the value of the current Credential for the given name
    #
    # @param credential_name [String] a CredHub credential name, e.g '/my-credential'
    # @return [String, Hash, RsaValue, SshValue, UserValue, CertificateValue, nil] the Credential#value if it exists
    def current_credential_value(credential_name)
      current_credential = credentials_by_name(credential_name, current: true).first
      current_credential && current_credential.value
    end

    # Retrieves a collection of Permissions for a Credential by Credential Name.
    #
    # @param credential_name [String] a CredHub credential name, e.g '/my-credential'
    # @return [CredHubble::Resources::PermissionCollection] a CredHubble::Resources::PermissionCollection instance,
    #   containing an enumerable list of Permissions
    def permissions_by_credential_name(credential_name)
      template = Addressable::Template.new('/api/v1/permissions{?query*}')

      query_args = { credential_name: credential_name }
      path = template.expand(query: query_args).to_s

      response = http_client.get(path).body
      CredHubble::Resources::PermissionCollection.from_json(response)
    end

    # Creates a new Credential or adds a new version of an existing Credential.
    #
    # @param credential [CredHubble::Resources::Credential] a CredHubble::Resources::Credential instance
    # @param overwrite [Boolean] whether or not CredHub should create a new current version for existing Credentials
    # @param additional_permissions [CredHubble::Resources::PermissionCollection]
    #   a CredHubble::Resources::PermissionCollection for additional Permissions to set on the credentials
    # @return [CredHubble::Resources::Credential] a CredHubble::Resources::Credential instance,
    #   e.g. CredHubble::Resources::CertificateCredential
    def put_credential(credential, overwrite: nil, additional_permissions: [])
      credential_body = credential.attributes_for_put
      credential_body[:overwrite] = !!overwrite unless overwrite.nil?

      unless additional_permissions.empty?
        credential_body[:additional_permissions] = additional_permissions.map(&:attributes)
      end

      response = http_client.put('/api/v1/data', credential_body.to_json).body
      CredHubble::Resources::CredentialFactory.from_json(response)
    end

    # Populates "credhub-ref" keys in a JSON string (e.g. ENV['VCAP_SERVICES']) with credential values.
    #
    # @param vcap_services_json [String] a valid JSON string including, particularly one from a Cloud Foundry app's
    #   VCAP_SERVICES environment variable
    # @return [String] a valid JSON string with populated CredHub references
    def interpolate_credentials(vcap_services_json)
      http_client.post('/api/v1/interpolate', vcap_services_json).body
    end

    # Deletes a Credential with the given Name.
    #
    # @param name [String] a CredHub credential name, e.g '/my-credential'
    # @return [Boolean] true if the deletion was successful
    def delete_credential_by_name(name)
      template = Addressable::Template.new('/api/v1/data{?query*}')

      query_args = { name: name }
      path = template.expand(query: query_args).to_s

      http_client.delete(path).success?
    end

    # Adds additional Permissions to an existing Credential. The Credential is specified by the `credential_name` field
    # on the PermissionCollection
    #
    # @param permission_collection [CredHubble::Resources::PermissionCollection]
    #   a CredHubble::Resources::PermissionCollection for additional Permissions to set on the credentials
    # @return [CredHubble::Resources::PermissionCollection] a CredHubble::Resources::PermissionCollection instance
    def add_permissions(permission_collection)
      response = http_client.post('/api/v1/permissions', permission_collection.to_json).body
      CredHubble::Resources::PermissionCollection.from_json(response)
    end

    # Deletes any permissions for the given actor for a Credential.
    #
    # @param credential_name [String] a CredHub credential name, e.g '/my-credential'
    # @param actor [String] a CredHub actor, e.g. 'uaa-user:fca1ae5e-f417-45ce-94b0-79889e27e047'
    # @return [Boolean] true if the deletion was successful
    def delete_permissions(credential_name, actor)
      template = Addressable::Template.new('/api/v1/permissions{?query*}')

      query_args = { credential_name: credential_name, actor: actor }
      path = template.expand(query: query_args).to_s

      http_client.delete(path).success?
    end

    private

    attr_reader :auth_header_token, :client_cert_path, :client_key_path, :ca_path, :host, :port

    def http_client
      CredHubble::Http::Client.new(
        credhub_url,
        auth_header_token: auth_header_token,
        ca_path: ca_path,
        client_cert: client_cert,
        client_key: client_key
      )
    end

    def client_cert
      return unless client_cert_path

      OpenSSL::X509::Certificate.new(File.read(client_cert_path))
    end

    def client_key
      return unless client_key_path

      OpenSSL::PKey::RSA.new(File.read(client_key_path))
    end

    def credhub_url
      Addressable::URI.new(scheme: 'https', host: host, port: port).to_s
    end
  end
end
# rubocop:enable ClassLength
