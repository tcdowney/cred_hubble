require 'cred_hubble/http/errors'
require 'faraday'

module CredHubble
  module Http
    class Client
      DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(url, auth_header_token: nil, credhub_ca_path: nil)
        @url = url
        @auth_header_token = auth_header_token
        @credhub_ca_path = credhub_ca_path
      end

      def get(path)
        with_error_handling do
          connection.get(path)
        end
      end

      private

      attr_reader :auth_header_token, :credhub_ca_path, :url

      def connection
        Faraday.new(url: url, headers: request_headers, ssl: ssl_config) do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end
      end

      def request_headers
        headers = DEFAULT_HEADERS
        return headers unless auth_header_token

        headers.merge('Authorization' => "bearer #{auth_header_token}")
      end

      def ssl_config
        config = { verify: true }
        return config unless credhub_ca_path

        config.merge(ca_file: credhub_ca_path)
      end

      def with_error_handling(&_block)
        response = yield

        return response if [200, 201, 202, 204].include?(response.status)

        raise_error_from_response(response)
      rescue Faraday::SSLError => e
        raise CredHubble::Http::SSLError, e
      end

      def raise_error_from_response(response)
        case response.status
        when 400
          raise BadRequestError.from_response(response)
        when 401
          raise UnauthorizedError.from_response(response)
        when 403
          raise ForbiddenError.from_response(response)
        when 404
          raise NotFoundError.from_response(response)
        when 500
          raise InternalServerError.from_response(response)
        else
          raise UnknownError.from_response(response)
        end
      end
    end
  end
end
