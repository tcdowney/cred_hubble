require 'cred_hubble/resources/rest_resource'
require 'virtus'

module CredHubble
  module Resources
    class Resource < RestResource
      include ::Virtus.model
    end
  end
end
