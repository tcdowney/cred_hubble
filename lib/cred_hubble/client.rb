require 'cred_hubble/resources/info'
require 'cred_hubble/resources/health'
require 'cred_hubble/http/client'

module CredHubble
  class Client
    def initialize(credhub_url:, auth_header_token: nil)
      @credhub_url = credhub_url
      @auth_header_token = auth_header_token
      @verify_ssl = true
    end

    def self.new_from_token(credhub_url:, auth_header_token:)
      new(credhub_url: credhub_url, auth_header_token: auth_header_token)
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
      CredHubble::Resources::Credential.from_json(response)
    end

    private

    attr_reader :auth_header_token, :credhub_url, :verify_ssl

    def http_client
      CredHubble::Http::Client.new(
        credhub_url,
        auth_header_token: auth_header_token,
        verify_ssl: verify_ssl
      )
    end

    # TODO: Remove ability to disable ssl verification
    # Only leaving this in to simplify initial development
    # Will be removed before the 0.0.1 release since non-SSL + CredHub is not a good combo
    def unsafe_mode!
      @verify_ssl = false
      puts 'WARNING: SSL verification disabled!'
    end
  end
end
