require 'cred_hubble/resources/base_resource'
require 'virtus'

module CredHubble
  module Resources
    class ImmutableResource < BaseResource
      include ::Virtus.value_object
    end
  end
end
