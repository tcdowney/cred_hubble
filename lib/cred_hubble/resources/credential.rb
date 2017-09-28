require 'cred_hubble/resources/immutable_resource'

module CredHubble
  module Resources
    class Credential < ImmutableResource
      VALUE_TYPE = 'value'.freeze

      attribute :id, String
      attribute :name, String
      attribute :type, String
      attribute :version_created_at, String

      def self.from_json(raw_json)
        parsed_json = parse_json(raw_json)

        case parsed_json['type']
        when VALUE_TYPE
          ValueCredential.new(parsed_json)
        else
          new(parsed_json)
        end
      end
    end
  end
end
