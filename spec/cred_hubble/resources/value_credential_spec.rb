require 'spec_helper'

RSpec.describe CredHubble::Resources::ValueCredential do
  subject { CredHubble::Resources::ValueCredential.new }

  let(:json_response) do
    '{
      "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
      "name": "/the-grid",
      "type": "value",
      "value": "biodigital-jazz-man",
      "version_created_at": "1985-01-01T01:01:01Z"
    }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::ValueCredential }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new ValueCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::ValueCredential)
        expect(credential.value).to eq('biodigital-jazz-man')
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#type' do
    it 'returns "value"' do
      subject.type = 'attempting-to-overwrite'
      expect(subject.type).to eq('value')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end
end
