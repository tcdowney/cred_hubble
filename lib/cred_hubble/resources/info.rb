require 'cred_hubble/resources/immutable_resource'

module CredHubble
  module Resources
    class AuthServerInfo < ImmutableResource
      attribute :url, String
    end

    class AppInfo < ImmutableResource
      attribute :name, String
      attribute :version, String
    end

    class Info < ImmutableResource
      attribute :auth_server, AuthServerInfo, default: AuthServerInfo.new
      attribute :app, AppInfo, default: AppInfo.new

      def self.from_json(raw_json)
        parsed_json = parse_json(raw_json)

        if parsed_json['auth-server']
          parsed_json[:auth_server] = parsed_json.delete('auth-server')
        end

        new(parsed_json)
      end
    end
  end
end
