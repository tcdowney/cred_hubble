require 'cred_hubble/resources/rest_resource'

module CredHubble
  module Resources
    class Permission < Resource
      attribute :actor, String
      attribute :operations, Array[String]
    end
  end
end
