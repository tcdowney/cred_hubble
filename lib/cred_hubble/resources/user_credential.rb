require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class UserValue
      include Virtus.model

      attribute :username, String
      attribute :password, String
      attribute :password_hash, String

      def to_json(options = {})
        attributes.to_json(options)
      end

      def attributes_for_put
        attributes.delete_if { |k, _| immutable_attributes.include?(k) }
      end

      private

      def immutable_attributes
        [:password_hash]
      end
    end

    class UserCredential < Credential
      attribute :value, UserValue

      def type
        Credential::USER_TYPE
      end

      def attributes_for_put
        super.merge(value: value && value.attributes_for_put)
      end
    end
  end
end
