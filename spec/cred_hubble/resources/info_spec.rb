require 'spec_helper'

RSpec.describe CredHubble::Resources::Info do
  describe '.from_json' do
    subject { CredHubble::Resources::Info }

    context 'when the JSON includes the required attributes' do
      let(:json_response) do
        '{
          "auth-server": {
            "url":"https://uaa.service.cf.internal:8443"
          },
          "app": {
            "name":"CredHub",
            "version":"1.2.0"
          }
        }'
      end

      it 'instantiates a new Info object with the correct values' do
        info = subject.from_json(json_response)
        expect(info.auth_server.url).to eq('https://uaa.service.cf.internal:8443')
        expect(info.app.name).to eq('CredHub')
        expect(info.app.version).to eq('1.2.0')
      end

      context 'when the JSON includes extra attributes' do
        let(:json_response) do
          '{
          "auth-server": {
            "url":"https://uaa.service.cf.internal:8443"
          },
          "app": {
            "name":"CredHub",
            "version":"1.2.0",
            "extra": "extra!"
          }
        }'
        end

        it 'instantiates a new Info object and ignores the extra fields' do
          info = subject.from_json(json_response)
          expect(info.auth_server.url).to eq('https://uaa.service.cf.internal:8443')
          expect(info.app.name).to eq('CredHub')
          expect(info.app.version).to eq('1.2.0')
          expect(info.app).to_not respond_to(:extra)
        end
      end
    end

    context 'when the JSON is missing attributes' do
      let(:json_response) { '{}' }

      it 'instantiates a new Info object and returns nil for the missing fields' do
        info = subject.from_json(json_response)
        expect(info.auth_server.url).to be_nil
        expect(info.app.name).to be_nil
        expect(info.app.version).to be_nil
      end
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::Info.new(app: { name: 'CredHub', version: '1.0' }) }

    it_behaves_like 'an immutable resource', :app
  end
end
