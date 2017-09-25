require 'cred_hubble/exceptions/error'
require 'json'

module CredHubble
  module Resources
    class JsonParseError < CredHubble::Exceptions::Error; end

    class BaseResource
      def self.from_json(json)
        new(parse_json(json))
      end

      def self.parse_json(raw_json)
        JSON.parse(raw_json)
      rescue JSON::ParserError => e
        raise CredHubble::Resources::JsonParseError, e.message
      end

      private_class_method :parse_json
    end
  end
end
