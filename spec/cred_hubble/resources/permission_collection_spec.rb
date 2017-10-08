require 'spec_helper'

RSpec.describe CredHubble::Resources::PermissionCollection do
  let(:json) do
    '{
      "credential_name": "/uaa-client-credentials",
      "permissions":[
        {
          "actor": "mtls-app:5532f504-bb27-43e1-94e9-bad794238f17",
          "operations": [
            "read",
            "write",
            "delete",
            "read_acl",
            "write_acl"
          ]
        },
        {
          "actor": "uaa-user:b2449249-5b51-4893-ab76-648763653c38",
          "operations": [
            "read",
            "write",
            "delete",
            "read_acl",
            "write_acl"
          ]
        }
      ]
    }'
  end

  subject { CredHubble::Resources::PermissionCollection.from_json(json) }

  describe '.from_json' do
    subject { CredHubble::Resources::PermissionCollection }

    it 'deserializes all of the permissions into Permission objects' do
      permission_collection = subject.from_json(json)
      expect(permission_collection.credential_name).to eq('/uaa-client-credentials')

      permissions = permission_collection.permissions
      expect(permissions).to all(be_a(CredHubble::Resources::Permission))
      expect(permissions.map(&:actor)).to match_array(
        %w[
          mtls-app:5532f504-bb27-43e1-94e9-bad794238f17
          uaa-user:b2449249-5b51-4893-ab76-648763653c38
        ]
      )
      expect(permissions.first.operations).to match_array(%w[read write delete read_acl write_acl])
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#each' do
    it 'is iterable' do
      expect(subject).to respond_to(:each)
      expect(subject.first).to be_a(CredHubble::Resources::Permission)
      expect(subject.map(&:actor)).to match_array(
        %w[
          mtls-app:5532f504-bb27-43e1-94e9-bad794238f17
          uaa-user:b2449249-5b51-4893-ab76-648763653c38
        ]
      )
    end
  end
end
