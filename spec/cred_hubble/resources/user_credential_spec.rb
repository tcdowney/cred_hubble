require 'spec_helper'

RSpec.describe CredHubble::Resources::UserCredential do
  let(:json_response) do
    '{
      "id": "15811465-8538-460d-9682-5514d44439fd",
      "name": "/admin-user",
      "type": "user",
      "value": {
        "username": "admin",
        "password": "2582aaf15ec84e3fa3ba682152663a52",
        "password_hash": "8efbef4cec28f228fa948daaf4893ac3638fbae81358ff9020be1d7a9a509fc6:1234"
      },
      "version_created_at": "1990-05-18T01:01:01Z"
    }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::UserCredential }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new UserCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::UserCredential)
        expect(credential.value.username).to eq('admin')
        expect(credential.value.password).to eq('2582aaf15ec84e3fa3ba682152663a52')
        expect(credential.value.password_hash)
          .to eq('8efbef4cec28f228fa948daaf4893ac3638fbae81358ff9020be1d7a9a509fc6:1234')
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#type' do
    it 'returns "user"' do
      subject.type = 'attempting-to-overwrite'
      expect(subject.type).to eq('user')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end

  describe '#attributes_for_put' do
    context 'when value is present' do
      it 'does not include the password_hash' do
        credential = CredHubble::Resources::UserCredential.from_json(json_response)
        expect(credential.attributes_for_put[:value]).to_not have_key(:password_hash)
      end
    end

    context 'when value is not present' do
      let(:json_response) do
        '{
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/admin-user",
          "type": "user",
          "version_created_at": "1990-05-18T01:01:01Z"
        }'
      end

      it 'does not a value' do
        credential = CredHubble::Resources::UserCredential.from_json(json_response)
        expect(credential.attributes_for_put[:value]).to be_nil
      end
    end
  end
end
