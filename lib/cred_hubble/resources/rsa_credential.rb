require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class RsaValue < ImmutableResource
      attribute :public_key, String
      attribute :private_key, String
    end

    class RsaCredential < Credential
      attribute :value, RsaValue

      def type
        Credential::RSA_TYPE
      end
    end
  end
end
