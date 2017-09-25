require 'cred_hubble/resources/immutable_resource'

module CredHubble
  module Resources
    class Health < ImmutableResource
      attribute :status, String
    end
  end
end
