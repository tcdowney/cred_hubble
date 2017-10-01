require 'spec_helper'

RSpec.describe CredHubble::Resources::JsonCredential do
  subject { CredHubble::Resources::JsonCredential.new }

  describe '.from_json' do
    subject { CredHubble::Resources::JsonCredential }

    context 'when the JSON includes the required attributes' do
      let(:json_response) do
        '{
          "id": "f2dcb184-cd60-4306-a858-166f44e8cacf",
          "name": "/backstreets-back-alright",
          "type": "json",
          "value": {
            "title": "Everybody",
            "album": "Backstreet\'s Back",
            "members": ["AJ McLean", "Howie D.", "Nick Carter", "Kevin Richardson", "Brian Littrell"]
          },
          "version_created_at": "1985-01-01T01:01:01Z"
        }'
      end

      it 'instantiates a new JsonCredential object' do
        credential = subject.from_json(json_response)

        expected_value = {
          'title' => 'Everybody',
          'album' => "Backstreet's Back",
          'members' => ['AJ McLean', 'Howie D.', 'Nick Carter', 'Kevin Richardson', 'Brian Littrell']
        }

        expect(credential).to be_a(CredHubble::Resources::JsonCredential)
        expect(credential.value).to eq(expected_value)
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::JsonCredential.new(value: '{"right proper json": "right proper"}') }

    it_behaves_like 'an immutable resource', :value
  end

  describe '#type' do
    it 'returns "json"' do
      expect(subject.type).to eq('json')
    end
  end

  describe '#type=' do
    it 'raises a NoMethodError' do
      expect { subject.type = 'foo' }.to raise_error(NoMethodError)
    end
  end
end
