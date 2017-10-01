require 'cred_hubble/resources/credential'

module CredHubble
  module Resources
    class CertificateValue < ImmutableResource
      attribute :ca, String
      attribute :certificate, String
      attribute :private_key, String
    end

    class CertificateCredential < Credential
      attribute :value, CertificateValue

      def type
        Credential::CERTIFICATE_TYPE
      end
    end
  end
end
