require 'cred_hubble/resources/immutable_resource'

module CredHubble
  module Resources
    class KeyUsage < ImmutableResource
      attribute :active_key, Numeric
      attribute :inactive_keys, Numeric
      attribute :unknown_keys, Numeric
    end
  end
end
