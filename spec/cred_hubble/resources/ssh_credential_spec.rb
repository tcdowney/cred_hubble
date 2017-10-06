require 'spec_helper'

RSpec.describe CredHubble::Resources::SshCredential do
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
      "version_created_at": "1990-05-16T01:01:01Z"
    }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::SshCredential }

    context 'when the JSON includes the required attributes' do
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

  describe '#type' do
    it 'returns "ssh"' do
      subject.type = 'attempting-to-overwrite'
      expect(subject.type).to eq('ssh')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end

  describe '#attributes_for_put' do
    context 'when value is present' do
      it 'does not include the public_key_fingerprint' do
        credential = CredHubble::Resources::SshCredential.from_json(json_response)
        expect(credential.attributes_for_put[:value]).to_not have_key(:public_key_fingerprint)
      end
    end

    context 'when value is not present' do
      let(:json_response) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/root-ssh-user",
          "type": "ssh",
          "version_created_at": "1990-03-29T01:07:01Z"
        }'
      end

      it 'does not include a value' do
        credential = CredHubble::Resources::SshCredential.from_json(json_response)
        expect(credential.attributes_for_put[:value]).to be_nil
      end
    end
  end
end
