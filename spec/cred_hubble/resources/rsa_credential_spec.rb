require 'spec_helper'

RSpec.describe CredHubble::Resources::RsaCredential do
  let(:json_response) do
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

  describe '.from_json' do
    subject { CredHubble::Resources::RsaCredential }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new RsaCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::RsaCredential)
        expect(credential.value.public_key)
          .to eq("-----BEGIN PUBLIC KEY-----\n... PUBLIC KEY ...\n-----END PUBLIC KEY-----")
        expect(credential.value.private_key)
          .to eq("-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----")
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#type' do
    it 'returns "rsa"' do
      subject.type = 'attempting-to-overwrite'
      expect(subject.type).to eq('rsa')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end
end
