require 'spec_helper'

RSpec.describe CredHubble::Resources::Permission do
  let(:json_response) do
    '{
      "actor": "mtls-app:5532f504-bb27-43e1-94e9-bad794238f17",
      "operations": [
        "read",
        "write",
        "delete",
        "read_acl",
        "write_acl"
      ]
    }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::Permission }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new Permission object' do
        permission = subject.from_json(json_response)

        expect(permission).to be_a(CredHubble::Resources::Permission)
        expect(permission.actor).to eq('mtls-app:5532f504-bb27-43e1-94e9-bad794238f17')
        expect(permission.operations).to match_array(%w[read write delete read_acl write_acl])
      end
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end
end
