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
