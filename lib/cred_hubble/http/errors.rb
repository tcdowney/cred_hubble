module CredHubble
  module Http
    class Error < CredHubble::Exceptions::Error
      def self.from_response(response)
        message = "status: #{response.status}, body: #{response.body}"
        new(message)
      end
    end

    class BadRequestError < Error
    end
    class UnauthorizedError < Error
    end
    class ForbiddenError < Error
    end
    class NotFoundError < Error
    end
    class InternalServerError < Error
    end
    class UnknownError < Error
    end
    class SSLError < Error
    end
  end
end
