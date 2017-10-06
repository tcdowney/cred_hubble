require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class SshValue
      include Virtus.model

      attribute :public_key, String
      attribute :private_key, String
      attribute :public_key_fingerprint, String

      def to_json(options = {})
        attributes.to_json(options)
      end

      def attributes_for_put
        attributes.delete_if { |k, _| immutable_attributes.include?(k) }
      end

      private

      def immutable_attributes
        [:public_key_fingerprint]
      end
    end

    class SshCredential < Credential
      attribute :value, SshValue

      def type
        Credential::SSH_TYPE
      end

      def attributes_for_put
        super.merge(value: value && value.attributes_for_put)
      end
    end
  end
end
