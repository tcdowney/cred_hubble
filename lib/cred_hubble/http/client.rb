require 'cred_hubble/http/errors'
require 'faraday'

module CredHubble
  module Http
    class Client
      DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(url, verify_ssl: true)
        @url = url
        @verify_ssl = verify_ssl
      end

      def get(path)
        with_error_handling do
          connection.get(path)
        end
      end

      private

      attr_reader :url, :verify_ssl

      def connection
        Faraday.new(url: url, headers: DEFAULT_HEADERS, ssl: { verify: verify_ssl }) do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end
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
