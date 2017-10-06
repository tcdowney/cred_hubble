require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class RsaValue
      include Virtus.model

      attribute :public_key, String
      attribute :private_key, String

      def to_json(options = {})
        attributes.to_json(options)
      end
    end

    class RsaCredential < Credential
      attribute :value, RsaValue

      def type
        Credential::RSA_TYPE
      end
    end
  end
end
