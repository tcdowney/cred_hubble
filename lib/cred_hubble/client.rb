require 'cred_hubble/resources/info'
require 'cred_hubble/resources/health'
require 'cred_hubble/http/client'

module CredHubble
  class Client
    def initialize(credhub_url)
      @credhub_url = credhub_url
      @verify_ssl = true
    end

    def info
      response = http_client.get('/info').body
      CredHubble::Resources::Info.from_json(response)
    end

    def health
      response = http_client.get('/health').body
      CredHubble::Resources::Health.from_json(response)
    end

    private

    attr_reader :credhub_url, :verify_ssl

    def http_client
      CredHubble::Http::Client.new(credhub_url, verify_ssl: verify_ssl)
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
