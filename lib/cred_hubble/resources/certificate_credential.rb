require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class CertificateValue
      include Virtus.model

      attribute :ca, String
      attribute :certificate, String
      attribute :private_key, String

      def to_json(options = {})
        attributes.to_json(options)
      end
    end

    class CertificateCredential < Credential
      attribute :value, CertificateValue

      def type
        Credential::CERTIFICATE_TYPE
      end
    end
  end
end
