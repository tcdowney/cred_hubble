require 'cred_hubble/resources/immutable_resource'

module CredHubble
  module Resources
    class Credential < ImmutableResource
      TYPES = [
        VALUE_TYPE = 'value'.freeze,
        JSON_TYPE = 'json'.freeze,
        PASSWORD_TYPE = 'password'.freeze,
        USER_TYPE = 'user'.freeze,
        CERTIFICATE_TYPE = 'certificate'.freeze,
        RSA_TYPE = 'rsa'.freeze,
        SSH_TYPE = 'ssh'.freeze
      ].freeze

      attribute :id, String
      attribute :name, String
      attribute :type, String
      attribute :version_created_at, String
    end
  end
end
