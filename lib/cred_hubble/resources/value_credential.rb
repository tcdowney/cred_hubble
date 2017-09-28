require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class ValueCredential < Credential
      attribute :value, String
    end
  end
end
