require 'spec_helper'

RSpec.describe CredHubble::Resources::CredentialFactory do
  describe '.from_json' do
    subject { CredHubble::Resources::CredentialFactory }

    context 'when the Credential type is "value"' do
      let(:value_json) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-grid",
          "type": "value",
          "value": "biodigital-jazz-man",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'returns instantiates a ValueCredential' do
        expect(subject.from_json(value_json)).to be_a(CredHubble::Resources::ValueCredential)
      end
    end

    context 'when the Credential type is "json"' do
      let(:json_json) do
        '{
          "id": "f2dcb184-cd60-4306-a858-166f44e8cacf",
          "name": "/backstreets-back-alright",
          "type": "json",
          "value": {
            "title": "Everybody",
            "album": "Backstreet\'s Back",
            "members": ["AJ McLean", "Howie D.", "Nick Carter", "Kevin Richardson", "Brian Littrell"]
          },
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'returns instantiates a JsonCredential' do
        expect(subject.from_json(json_json)).to be_a(CredHubble::Resources::JsonCredential)
      end
    end

    context 'when the Credential type is "password"' do
      let(:password_json) do
        '{
          "id": "b1a124c5-3faf-426f-9f8f-fe695b36a4e2",
          "name": "/top-secret-password",
          "type": "password",
          "value": "p4ssw0rd",
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'returns instantiates a PasswordCredential' do
        expect(subject.from_json(password_json)).to be_a(CredHubble::Resources::PasswordCredential)
      end
    end

    context 'when the Credential type is "user"' do
      let(:user_json) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/admin-user",
          "type": "user",
          "value": {
            "username": "admin",
            "password": "2582aaf15ec84e3fa3ba682152663a52",
            "password_hash": "8efbef4cec28f228fa948daaf4893ac3638fbae81358ff9020be1d7a9a509fc6:1234"
          },
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'returns instantiates a UserCredential' do
        expect(subject.from_json(user_json)).to be_a(CredHubble::Resources::UserCredential)
      end
    end

    context 'when the Credential type is "certificate"' do
      let(:certificate_json) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/load-balancer-tls-cert",
          "type": "certificate",
          "value": {
            "ca": "-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----",
            "certificate": "-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
          },
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'returns instantiates a CertificateCredential' do
        expect(subject.from_json(certificate_json)).to be_a(CredHubble::Resources::CertificateCredential)
      end
    end

    context 'when the Credential type is "rsa"' do
      let(:rsa_json) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/rsa-key-1",
          "type": "rsa",
          "value": {
            "public_key": "-----BEGIN PUBLIC KEY-----\n... PUBLIC KEY ...\n-----END PUBLIC KEY-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
          },
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'returns instantiates a RsaCredential' do
        expect(subject.from_json(rsa_json)).to be_a(CredHubble::Resources::RsaCredential)
      end
    end

    context 'when the Credential type is "ssh"' do
      let(:ssh_json) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/ssh-key-1",
          "type": "ssh",
          "value": {
            "public_key": "ssh-rsa AAAAB3NzaC1y...",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----",
            "public_key_fingerprint": "9db6ee01f7963db4e8c9966f3c425fd3feeadc148f37b428ddce2a458bd50da6"
          },
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'returns instantiates a SshCredential' do
        expect(subject.from_json(ssh_json)).to be_a(CredHubble::Resources::SshCredential)
      end
    end

    context 'when the Credential type is unknown' do
      let(:value_json_response) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-digital-frontier",
          "type": "who-knows-man",
          "value": "🌝",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'returns instantiates a base Credential' do
        expect(subject.from_json(value_json_response)).to be_a(CredHubble::Resources::Credential)
      end
    end
  end
end
