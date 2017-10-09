require 'cred_hubble/resources/rest_resource'
require 'cred_hubble/resources/permission'

module CredHubble
  module Resources
    class PermissionCollection < Resource
      include Enumerable

      attribute :credential_name, String
      attribute :permissions, Array[Permission]

      def each(&block)
        permissions.each(&block)
      end

      def empty?
        permissions.empty?
      end
    end
  end
end
