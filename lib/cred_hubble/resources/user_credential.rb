require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class UserValue < ImmutableResource
      attribute :username, String
      attribute :password, String
      attribute :password_hash, String
    end

    class UserCredential < Credential
      attribute :value, UserValue

      def type
        Credential::USER_TYPE
      end
    end
  end
end
