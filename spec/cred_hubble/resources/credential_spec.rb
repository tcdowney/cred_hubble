require 'spec_helper'

RSpec.describe CredHubble::Resources::Credential do
  describe '.from_json' do
    subject { CredHubble::Resources::Credential }

    context 'when the Credential type is "value"' do
      let(:value_json_response) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-grid",
          "type": "value",
          "value": "biodigital-jazz-man",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'returns instantiates a ValueCredential' do
        expect(subject.from_json(value_json_response)).to be_a(CredHubble::Resources::ValueCredential)
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

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::Credential.new(name: '/the-grid') }

    it_behaves_like 'an immutable resource', :name
  end
end
