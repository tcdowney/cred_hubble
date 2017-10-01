require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class PasswordCredential < Credential
      attribute :value, String

      def type
        Credential::PASSWORD_TYPE
      end
    end
  end
end
