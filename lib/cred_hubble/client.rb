require 'cred_hubble/resources/info'
require 'cred_hubble/resources/health'
require 'cred_hubble/http/client'

module CredHubble
  class Client
    def initialize(credhub_url:, auth_header_token: nil, credhub_ca_path: nil)
      @credhub_url = credhub_url
      @auth_header_token = auth_header_token
      @credhub_ca_path = credhub_ca_path
    end

    def self.new_from_token(credhub_url:, auth_header_token:, credhub_ca_path: nil)
      new(
        credhub_url: credhub_url,
        auth_header_token: auth_header_token,
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

    private

    attr_reader :auth_header_token, :credhub_url, :credhub_ca_path

    def http_client
      CredHubble::Http::Client.new(
        credhub_url,
        auth_header_token: auth_header_token,
        credhub_ca_path: credhub_ca_path
      )
    end
  end
end
