require 'spec_helper'

RSpec.describe CredHubble::Resources::ValueCredential do
  subject { CredHubble::Resources::ValueCredential.new }

  describe '.from_json' do
    subject { CredHubble::Resources::ValueCredential }

    context 'when the JSON includes the required attributes' do
      let(:json_response) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-grid",
          "type": "value",
          "value": "biodigital-jazz-man",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'instantiates a new ValueCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::ValueCredential)
        expect(credential.value).to eq('biodigital-jazz-man')
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::ValueCredential.new(value: 'biodigital-jazz-man') }

    it_behaves_like 'an immutable resource', :value
  end

  describe '#type' do
    it 'returns "value"' do
      expect(subject.type).to eq('value')
    end
  end

  describe '#type=' do
    it 'raises a NoMethodError' do
      expect { subject.type = 'foo' }.to raise_error(NoMethodError)
    end
  end
end
