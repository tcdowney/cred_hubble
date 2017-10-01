require 'cred_hubble/resources/base_resource'
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
    class CredentialFactory < BaseResource
      def self.from_json(raw_json)
        parsed_json = parse_json(raw_json)

        case parsed_json['type']
        when Credential::VALUE_TYPE
          ValueCredential.new(parsed_json)
        when Credential::JSON_TYPE
          JsonCredential.new(parsed_json)
        when Credential::PASSWORD_TYPE
          PasswordCredential.new(parsed_json)
        when Credential::USER_TYPE
          UserCredential.new(parsed_json)
        when Credential::CERTIFICATE_TYPE
          CertificateCredential.new(parsed_json)
        when Credential::RSA_TYPE
          RsaCredential.new(parsed_json)
        when Credential::SSH_TYPE
          SshCredential.new(parsed_json)
        else
          Credential.new(parsed_json)
        end
      end
    end
  end
end
