require 'spec_helper'

RSpec.describe CredHubble::Resources::SshCredential do
  describe '.from_json' do
    subject { CredHubble::Resources::SshCredential }

    context 'when the JSON includes the required attributes' do
      let(:json_response) do
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

      it 'instantiates a new SshCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::SshCredential)
        expect(credential.value.public_key).to eq('ssh-rsa AAAAB3NzaC1y...')
        expect(credential.value.private_key)
          .to eq("-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----")
        expect(credential.value.public_key_fingerprint)
          .to eq('9db6ee01f7963db4e8c9966f3c425fd3feeadc148f37b428ddce2a458bd50da6')
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject do
      CredHubble::Resources::SshCredential.new(value: '{
        "value": {
            "username": "admin",
            "password": "2582aaf15ec84e3fa3ba682152663a52",
            "password_hash": "8efbef4cec28f228fa948daaf4893ac3638fbae81358ff9020be1d7a9a509fc6:1234"
          }
        }')
    end

    it_behaves_like 'an immutable resource', :value
  end

  describe '#type' do
    it 'returns "ssh"' do
      expect(subject.type).to eq('ssh')
    end
  end

  describe '#type=' do
    it 'raises a NoMethodError' do
      expect { subject.type = 'foo' }.to raise_error(NoMethodError)
    end
  end
end
