require 'cred_hubble/resources/base_resource'

module CredHubble
  module Resources
    class Permission < BaseResource
      include Virtus.model

      attribute :actor, String
      attribute :operations, Array[String]
    end
  end
end
