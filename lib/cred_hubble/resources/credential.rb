require 'cred_hubble/resources/base_resource'

module CredHubble
  module Resources
    class Credential < BaseResource
      include Virtus.model

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

      def attributes_for_put
        attributes.delete_if { |k, _| immutable_attributes.include?(k) }
      end

      private

      def immutable_attributes
        %i[id version_created_at]
      end
    end
  end
end
