RSpec.shared_examples 'an immutable resource' do |attribute|
  it 'will not allow attributes to be updated on the subject' do
    expect { subject.public_send("#{attribute}=", {}) }.to raise_error(NoMethodError, /#{Regexp.quote(attribute)}/)
  end
end

RSpec.shared_examples 'a JSON deserializing resource' do
  context 'when provided invalid JSON' do
    let(:invalid_json_response) { 'not valid json' }

    it 'raises a JSON parse error' do
      expect { subject.from_json(invalid_json_response) }.to raise_error(CredHubble::Resources::JsonParseError)
    end
  end
end

RSpec.shared_examples 'a JSON serializing resource' do
  describe '#to_json' do
    it 'correctly serializes complex attributes as JSON' do
      expect(JSON.parse(described_class.from_json(json_response).to_json)).to eq(JSON.parse(json_response))
    end
  end
end

RSpec.shared_examples 'a Credential resource' do
  describe '.from_json' do
    context 'when the JSON includes the required attributes' do
      let(:json_response) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-grid",
          "type": "value",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'instantiates a new Credential object with the correct values' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::Credential)
        expect(credential.id).to eq('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
        expect(credential.name).to eq('/the-grid')
        expect(credential.version_created_at).to eq('1985-01-01T01:01:01Z')
      end
    end

    describe '#attributes_for_put' do
      let(:json_response) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/the-grid",
          "type": "value",
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'returns only the attributes that can be updated with CredHub' do
        credential = subject.from_json(json_response)
        expect(credential.attributes_for_put.keys).to_not include :id
        expect(credential.attributes_for_put.keys).to_not include :version_created_at
      end
    end
  end
end
