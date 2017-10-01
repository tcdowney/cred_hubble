require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class SshValue < ImmutableResource
      attribute :public_key, String
      attribute :private_key, String
      attribute :public_key_fingerprint, String
    end

    class SshCredential < Credential
      attribute :value, SshValue

      def type
        Credential::SSH_TYPE
      end
    end
  end
end
