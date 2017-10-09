require 'cred_hubble/resources/rest_resource'
require 'cred_hubble/resources/credential'
require 'cred_hubble/resources/value_credential'
require 'cred_hubble/resources/json_credential'
require 'cred_hubble/resources/password_credential'
require 'cred_hubble/resources/user_credential'
require 'cred_hubble/resources/certificate_credential'
require 'cred_hubble/resources/rsa_credential'
require 'cred_hubble/resources/ssh_credential'

module CredHubble
  module Resources
    class CredentialFactory < RestResource
      def self.from_json(raw_json)
        parsed_json = parse_json(raw_json)
        credential_from_data(parsed_json)
      end

      def self.credential_from_data(credential_data)
        case credential_data['type']
        when Credential::VALUE_TYPE
          ValueCredential.new(credential_data)
        when Credential::JSON_TYPE
          JsonCredential.new(credential_data)
        when Credential::PASSWORD_TYPE
          PasswordCredential.new(credential_data)
        when Credential::USER_TYPE
          UserCredential.new(credential_data)
        when Credential::CERTIFICATE_TYPE
          CertificateCredential.new(credential_data)
        when Credential::RSA_TYPE
          RsaCredential.new(credential_data)
        when Credential::SSH_TYPE
          SshCredential.new(credential_data)
        else
          Credential.new(credential_data)
        end
      end
    end
  end
end
