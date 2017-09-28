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

RSpec.shared_examples 'a Credential resource' do
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

    it 'instantiates a new Credential object with the correct values' do
      credential = subject.from_json(json_response)
      expect(credential.id).to eq('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
      expect(credential.name).to eq('/the-grid')
      expect(credential.type).to eq('value')
      expect(credential.version_created_at).to eq('1985-01-01T01:01:01Z')
    end
  end
end
