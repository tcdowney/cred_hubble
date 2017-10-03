require 'spec_helper'

RSpec.describe CredHubble::Resources::CredentialCollection do
  let(:json) do
    '{
        "data":[
          {
            "type":"value",
            "version_created_at":"2017-10-03T04:12:21Z",
            "id":"5298e0e4-c3f5-4c73-a156-9ffce4c137f5",
            "name":"/hello-dolly-credz",
            "value":"Put on your Sunday clothes there\'s lots of world out there"
          },
          {
            "type":"value",
            "version_created_at":"2017-10-03T04:12:19Z",
            "id":"6980ec59-c7e6-449a-b525-298648cfe6a7",
            "name":"/hello-dolly-credz",
            "value":"Get out the brilliantine and dime cigars"
          },
          {
            "type":"value",
            "version_created_at":"2017-10-02T01:56:54Z",
            "id":"3e709d6e-585c-4526-ac0d-fe99316f2255",
            "name":"/hello-dolly-credz",
            "value":"We\'re gonna find adventure in the evening air"
          }
        ]
      }'
  end

  subject { CredHubble::Resources::CredentialCollection.from_json(json) }

  describe '.from_json' do
    subject { CredHubble::Resources::CredentialCollection }

    it 'deserializes all of the credentials into Credential objects' do
      credentials = subject.from_json(json).data
      expect(credentials).to all(be_a(CredHubble::Resources::ValueCredential))
      expect(credentials.map(&:name)).to match_array(%w[/hello-dolly-credz /hello-dolly-credz /hello-dolly-credz])
      expect(credentials.map(&:id)).to match_array(
        %w[
          5298e0e4-c3f5-4c73-a156-9ffce4c137f5
          6980ec59-c7e6-449a-b525-298648cfe6a7
          3e709d6e-585c-4526-ac0d-fe99316f2255
        ]
      )
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#each' do
    it 'is iterable' do
      expect(subject).to respond_to(:each)
      expect(subject.map(&:name)).to match_array(%w[/hello-dolly-credz /hello-dolly-credz /hello-dolly-credz])
    end
  end
end
