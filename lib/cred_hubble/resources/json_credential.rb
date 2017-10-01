require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class JsonCredential < Credential
      attribute :value, Hash

      def type
        Credential::JSON_TYPE
      end
    end
  end
end
