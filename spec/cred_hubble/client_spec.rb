require 'spec_helper'

RSpec.describe CredHubble::Client do
  let(:mock_http_client) { instance_double(CredHubble::Http::Client) }
  let(:mock_response) { instance_double(Faraday::Response, body: response_body) }
  let(:response_body) { '{}' }

  let(:credhub_url) { 'https://credhub.cloudfoundry.com:8845' }
  subject { CredHubble::Client.new(credhub_url: credhub_url) }

  before do
    allow(subject).to receive(:http_client).and_return(mock_http_client)
    allow(mock_http_client).to receive(:get).and_return(mock_response)
  end

  describe '.new_from_token' do
    let(:token) { 'example-token-string' }

    it 'instantiates an instance of the client with an oAuth2 bearer token' do
      client = CredHubble::Client.new_from_token(credhub_url: credhub_url, auth_header_token: token)
      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:auth_header_token)).to eq(token)
    end
  end

  describe '#info' do
    let(:response_body) do
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

    it 'makes a request to the /info endpoint' do
      subject.info
      expect(mock_http_client).to have_received(:get).with('/info')
    end

    it 'returns an Info resource' do
      info = subject.info
      expect(info.auth_server.url).to eq('https://uaa.service.cf.internal:8443')
      expect(info.app.version).to eq('1.2.0')
    end
  end

  describe '#health' do
    let(:response_body) { '{"status": "UP"}' }

    it 'makes a request to the /health endpoint' do
      subject.health
      expect(mock_http_client).to have_received(:get).with('/health')
    end

    it 'returns a Health resource' do
      health = subject.health
      expect(health.status).to eq('UP')
    end
  end

  describe '#credential_by_id' do
    let(:response_body) do
      '{
        "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
        "name": "/the-grid",
        "type": "value",
        "value": "biodigital-jazz-man",
        "version_created_at": "1985-01-01T01:01:01Z"
      }'
    end

    it 'makes a request to the /api/v1/data endpoint for the given credential id' do
      subject.credential_by_id('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
      expect(mock_http_client).to have_received(:get).with('/api/v1/data/cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
    end

    it 'returns a Credential resource' do
      credential = subject.credential_by_id('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
      expect(credential).to be_a(CredHubble::Resources::Credential)
      expect(credential.name).to eq('/the-grid')
      expect(credential.version_created_at).to eq('1985-01-01T01:01:01Z')
    end
  end
end
