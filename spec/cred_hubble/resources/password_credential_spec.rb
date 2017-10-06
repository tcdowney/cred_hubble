require 'spec_helper'

RSpec.describe CredHubble::Resources::PasswordCredential do
  let(:json_response) do
    '{
      "id": "b1a124c5-3faf-426f-9f8f-fe695b36a4e2",
      "name": "/top-secret-password",
      "type": "password",
      "value": "p4ssw0rd",
      "version_created_at": "1990-05-18T01:01:01Z"
    }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::PasswordCredential }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new PasswordCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::PasswordCredential)
        expect(credential.value).to eq('p4ssw0rd')
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#type' do
    it 'returns "password"' do
      subject.type = 'attempting-to-overwrite'

      expect(subject.type).to eq('password')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end
end
