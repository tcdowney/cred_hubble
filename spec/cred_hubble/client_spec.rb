require 'spec_helper'

RSpec.describe CredHubble::Client do
  let(:mock_http_client) { instance_double(CredHubble::Http::Client) }
  let(:mock_response) { instance_double(Faraday::Response, body: response_body) }
  let(:response_body) { '{}' }

  let(:credhub_url) { 'https://credhub.cloudfoundry.com:8845' }
  let(:credhub_ca_path) { '/custom/certs/ca.crt' }
  subject { CredHubble::Client.new(credhub_url: credhub_url) }

  before do
    allow(CredHubble::Http::Client).to receive(:new).and_return(mock_http_client)
    allow(mock_http_client).to receive(:get).and_return(mock_response)
  end

  describe '.new_from_token_auth' do
    let(:token) { 'example-token-string' }

    it 'instantiates an instance of the client with an oAuth2 bearer token' do
      client = CredHubble::Client.new_from_token_auth(credhub_url: credhub_url, auth_header_token: token)
      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:auth_header_token)).to eq(token)
    end

    it 'allows the user to optionally supply a file path for the CredHub CA cert' do
      client = CredHubble::Client.new_from_token_auth(
        credhub_url: credhub_url,
        auth_header_token: token,
        credhub_ca_path: credhub_ca_path
      )

      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:auth_header_token)).to eq(token)
      expect(client.send(:credhub_ca_path)).to eq(credhub_ca_path)
    end
  end

  describe '.new_from_mtls_auth' do
    let(:client_cert_path) { '/mutual/tls/certs/example-cert.crt' }
    let(:client_key_path) { '/mutual/tls/keys/rsa.pem' }
    let(:mock_cert_file) { instance_double(File) }
    let(:mock_key_file) { instance_double(File) }
    let(:mock_cert) { instance_double(OpenSSL::X509::Certificate) }
    let(:mock_key) { instance_double(OpenSSL::PKey::RSA) }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(client_cert_path).and_return(mock_cert_file)
      allow(File).to receive(:read).with(client_key_path).and_return(mock_key_file)

      allow(OpenSSL::X509::Certificate).to receive(:new).with(mock_cert_file).and_return(mock_cert)
      allow(OpenSSL::PKey::RSA).to receive(:new).with(mock_key_file).and_return(mock_key)
    end

    it 'instantiates an instance of the client with an oAuth2 bearer token' do
      client = CredHubble::Client.new_from_mtls_auth(
        credhub_url: credhub_url,
        client_cert_path: client_cert_path,
        client_key_path: client_key_path
      )

      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:client_cert_path)).to eq(client_cert_path)
      expect(client.send(:client_key_path)).to eq(client_key_path)
      expect(client.send(:client_cert)).to eq(mock_cert)
      expect(client.send(:client_key)).to eq(mock_key)
    end

    it 'allows the user to optionally supply a file path for the CredHub CA cert' do
      client = CredHubble::Client.new_from_mtls_auth(
        credhub_url: credhub_url,
        credhub_ca_path: credhub_ca_path,
        client_cert_path: client_cert_path,
        client_key_path: client_key_path
      )

      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:credhub_ca_path)).to eq(credhub_ca_path)
      expect(client.send(:client_cert_path)).to eq(client_cert_path)
      expect(client.send(:client_key_path)).to eq(client_key_path)
      expect(client.send(:client_cert)).to eq(mock_cert)
      expect(client.send(:client_key)).to eq(mock_key)
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
          "id": "15811465-8538-460d-9682-5514d44439fd",
          "name": "/load-balancer-tls-cert",
          "type": "certificate",
          "value": {
            "ca": "-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----",
            "certificate": "-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
          },
          "version_created_at": "1990-01-05T01:01:01Z"
        }'
    end

    it 'makes a request to the /api/v1/data endpoint for the given credential id' do
      subject.credential_by_id('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
      expect(mock_http_client).to have_received(:get).with('/api/v1/data/cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
    end

    it 'returns a Credential resource' do
      credential = subject.credential_by_id('cdbb371a-cc03-4a6f-aa21-c6461d66ed96')
      expect(credential).to be_a(CredHubble::Resources::CertificateCredential)
      expect(credential.name).to eq('/load-balancer-tls-cert')
      expect(credential.version_created_at).to eq('1990-01-05T01:01:01Z')
    end
  end

  describe '#credentials_by_name' do
    let(:response_body) do
      '{
        "data":[
          {
            "type":"password",
            "version_created_at":"2017-10-03T04:12:21Z",
            "id":"5298e0e4-c3f5-4c73-a156-9ffce4c137f5",
            "name":"/sunday-clothes-creds",
            "value":"Put on your Sunday clothes there\'s lots of world out there"
          },
          {
            "type":"password",
            "version_created_at":"2017-10-03T04:12:19Z",
            "id":"6980ec59-c7e6-449a-b525-298648cfe6a7",
            "name":"/sunday-clothes-creds",
            "value":"Get out the brilliantine and dime cigars"
          },
          {
            "type":"password",
            "version_created_at":"2017-10-02T01:56:54Z",
            "id":"3e709d6e-585c-4526-ac0d-fe99316f2255",
            "name":"/sunday-clothes-creds",
            "value":"We\'re gonna find adventure in the evening air"
          }
        ]
      }'
    end

    it 'makes a request to the /api/v1/data endpoint with the name as a query parameter' do
      subject.credentials_by_name('/sunday-clothes-creds')
      expect(mock_http_client).to have_received(:get).with('/api/v1/data?name=%2Fsunday-clothes-creds')
    end

    it 'includes optional current and version parameters when provided' do
      subject.credentials_by_name('/sunday-clothes-creds', current: false, versions: 100)
      expect(mock_http_client).to have_received(:get)
        .with('/api/v1/data?name=%2Fsunday-clothes-creds&current=false&versions=100')
    end

    it 'returns a CredentialCollection' do
      credentials = subject.credentials_by_name('/sunday-clothes-creds')
      expect(credentials).to all(be_a(CredHubble::Resources::PasswordCredential))
      expect(credentials.map(&:id)).to match_array(
        %w[
          5298e0e4-c3f5-4c73-a156-9ffce4c137f5
          6980ec59-c7e6-449a-b525-298648cfe6a7
          3e709d6e-585c-4526-ac0d-fe99316f2255
        ]
      )
    end
  end
end
