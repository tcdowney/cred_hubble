require 'addressable'
require 'cred_hubble/resources/resources'
require 'cred_hubble/http/client'
require 'openssl'

module CredHubble
  class Client
    def initialize(host:, port: 8844, auth_header_token: nil, ca_path: nil,
                   client_cert_path: nil, client_key_path: nil)

      @host = host
      @port = port
      @auth_header_token = auth_header_token
      @ca_path = ca_path
      @client_cert_path = client_cert_path
      @client_key_path = client_key_path
    end

    def self.new_from_token_auth(host:, port: 8844, auth_header_token:, ca_path: nil)
      new(
        auth_header_token: auth_header_token,
        ca_path: ca_path,
        host: host,
        port: port
      )
    end

    def self.new_from_mtls_auth(host:, port: 8844, client_cert_path:, client_key_path:, ca_path: nil)
      new(
        client_cert_path: client_cert_path,
        client_key_path: client_key_path,
        host: host,
        ca_path: ca_path,
        port: port
      )
    end

    def info
      response = http_client.get('/info').body
      CredHubble::Resources::Info.from_json(response)
    end

    def health
      response = http_client.get('/health').body
      CredHubble::Resources::Health.from_json(response)
    end

    def credential_by_id(credential_id)
      response = http_client.get("/api/v1/data/#{credential_id}").body
      CredHubble::Resources::CredentialFactory.from_json(response)
    end

    def credentials_by_name(name, current: nil, versions: nil)
      template = Addressable::Template.new('/api/v1/data{?query*}')

      query_args = { name: name, current: current, versions: versions }.reject { |_, v| v.nil? }
      path = template.expand(query: query_args).to_s

      response = http_client.get(path).body
      CredHubble::Resources::CredentialCollection.from_json(response)
    end

    def permissions_by_credential_name(credential_name)
      template = Addressable::Template.new('/api/v1/permissions{?query*}')

      query_args = { credential_name: credential_name }
      path = template.expand(query: query_args).to_s

      response = http_client.get(path).body
      CredHubble::Resources::PermissionCollection.from_json(response)
    end

    def put_credential(credential, overwrite: nil, additional_permissions: [])
      credential_body = credential.attributes_for_put
      credential_body[:overwrite] = !!overwrite unless overwrite.nil?

      unless additional_permissions.empty?
        credential_body[:additional_permissions] = additional_permissions.map(&:attributes)
      end

      response = http_client.put('/api/v1/data', credential_body.to_json).body
      CredHubble::Resources::CredentialFactory.from_json(response)
    end

    def interpolate_credentials(vcap_services_json)
      http_client.post('/api/v1/interpolate', vcap_services_json).body
    end

    def delete_credential_by_name(name)
      template = Addressable::Template.new('/api/v1/data{?query*}')

      query_args = { name: name }
      path = template.expand(query: query_args).to_s

      http_client.delete(path).success?
    end

    def add_permissions(permission_collection)
      response = http_client.post('/api/v1/permissions', permission_collection.to_json).body
      CredHubble::Resources::PermissionCollection.from_json(response)
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
