require 'cred_hubble/resources/rest_resource'
require 'virtus'

module CredHubble
  module Resources
    class ImmutableResource < RestResource
      include ::Virtus.value_object
    end
  end
end
