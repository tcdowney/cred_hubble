require 'cred_hubble/resources/base_resource'
require 'cred_hubble/resources/credential_factory'

module CredHubble
  module Resources
    class CredentialCollection < BaseResource
      include Enumerable

      def initialize(value_hash)
        credentials_array = value_hash['data']
        @data = credentials_array.map { |credential_data| CredentialFactory.credential_from_data(credential_data) }
      end

      def each(&block)
        data.each(&block)
      end

      attr_reader :data
    end
  end
end
