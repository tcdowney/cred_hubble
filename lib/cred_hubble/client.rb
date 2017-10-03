require 'addressable'
require 'cred_hubble/resources/resources'
require 'cred_hubble/http/client'
require 'openssl'

module CredHubble
  class Client
    def initialize(credhub_url:, auth_header_token: nil, credhub_ca_path: nil,
                   client_cert_path: nil, client_key_path: nil)

      @credhub_url = credhub_url
      @auth_header_token = auth_header_token
      @credhub_ca_path = credhub_ca_path
      @client_cert_path = client_cert_path
      @client_key_path = client_key_path
    end

    def self.new_from_token_auth(credhub_url:, auth_header_token:, credhub_ca_path: nil)
      new(
        auth_header_token: auth_header_token,
        credhub_ca_path: credhub_ca_path,
        credhub_url: credhub_url
      )
    end

    def self.new_from_mtls_auth(credhub_url:, client_cert_path:, client_key_path:, credhub_ca_path: nil)
      new(
        client_cert_path: client_cert_path,
        client_key_path: client_key_path,
        credhub_url: credhub_url,
        credhub_ca_path: credhub_ca_path
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

    private

    attr_reader :auth_header_token, :client_cert_path, :client_key_path, :credhub_ca_path, :credhub_url

    def http_client
      CredHubble::Http::Client.new(
        credhub_url,
        auth_header_token: auth_header_token,
        credhub_ca_path: credhub_ca_path,
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
  end
end
