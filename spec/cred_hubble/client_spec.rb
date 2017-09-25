require 'spec_helper'

RSpec.describe CredHubble::Client do
  let(:mock_http_client) { instance_double(CredHubble::Http::Client) }
  let(:credhub_url) { 'https://credhub.cloudfoundry.com:8845' }
  let(:mock_response) { instance_double(Faraday::Response, body: response_body) }
  subject { CredHubble::Client.new(credhub_url) }

  before do
    allow(subject).to receive(:http_client).and_return(mock_http_client)
    allow(mock_http_client).to receive(:get).and_return(mock_response)
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
end
