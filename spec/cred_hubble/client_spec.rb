require 'spec_helper'

RSpec.describe CredHubble::Client do
  let(:response_body) { '{}' }
  let(:response_status) { 200 }
  let(:mock_http_client) { instance_double(CredHubble::Http::Client) }
  let(:mock_response) do
    instance_double(Faraday::Response, status: response_status, body: response_body, success?: true)
  end

  let(:credhub_url) { 'https://credhub.cloudfoundry.com:8845' }
  let(:credhub_host) { 'credhub.cloudfoundry.com' }
  let(:credhub_port) { '8845' }
  let(:ca_path) { '/custom/certs/ca.crt' }
  subject { CredHubble::Client.new(host: credhub_host, port: credhub_port) }

  before do
    allow(CredHubble::Http::Client).to receive(:new).and_return(mock_http_client)
    allow(mock_http_client).to receive(:get).and_return(mock_response)
    allow(mock_http_client).to receive(:put).and_return(mock_response)
    allow(mock_http_client).to receive(:post).and_return(mock_response)
    allow(mock_http_client).to receive(:delete).and_return(mock_response)
  end

  describe '.new_from_token_auth' do
    let(:token) { 'example-token-string' }

    it 'instantiates an instance of the client with an oAuth2 bearer token' do
      client = CredHubble::Client.new_from_token_auth(
        host: credhub_host,
        port: credhub_port,
        auth_header_token: token
      )
      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:auth_header_token)).to eq(token)
    end

    it 'allows the user to optionally supply a file path for the CredHub CA cert' do
      client = CredHubble::Client.new_from_token_auth(
        host: credhub_host,
        port: credhub_port,
        auth_header_token: token,
        ca_path: ca_path
      )

      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:auth_header_token)).to eq(token)
      expect(client.send(:ca_path)).to eq(ca_path)
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

    it 'instantiates an instance of the client with a client cert and client key' do
      client = CredHubble::Client.new_from_mtls_auth(
        host: credhub_host,
        port: credhub_port,
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
        host: credhub_host,
        port: credhub_port,
        ca_path: ca_path,
        client_cert_path: client_cert_path,
        client_key_path: client_key_path
      )

      expect(client.send(:credhub_url)).to eq(credhub_url)
      expect(client.send(:ca_path)).to eq(ca_path)
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

  describe '#permissions_by_credential_name' do
    let(:response_body) do
      '{
        "credential_name": "/uaa-client-creds",
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

    it 'makes a request to the /api/v1/permissions endpoint with the credential_name as a query parameter' do
      subject.permissions_by_credential_name('/uaa-client-creds')
      expect(mock_http_client).to have_received(:get).with('/api/v1/permissions?credential_name=%2Fuaa-client-creds')
    end

    it 'returns a PermissionCollection' do
      permissions = subject.permissions_by_credential_name('/uaa-client-creds')
      expect(permissions).to all(be_a(CredHubble::Resources::Permission))
      expect(permissions.map(&:actor)).to match_array(
        %w[
          mtls-app:5532f504-bb27-43e1-94e9-bad794238f17
          uaa-user:b2449249-5b51-4893-ab76-648763653c38
        ]
      )
    end
  end

  describe '#put_credential' do
    let(:new_credential) do
      CredHubble::Resources::CertificateCredential.new(
        name: '/load-balancer-tls-cert',
        value: {
          ca: "-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----",
          certificate: "-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----",
          private_key: "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
        }
      )
    end
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

    it 'makes a PUT request to the /api/v1/data endpoint with the serialized credential' do
      subject.put_credential(new_credential)
      expect(mock_http_client).to have_received(:put).with('/api/v1/data', new_credential.attributes_for_put.to_json)
    end

    it 'accepts an optional overwrite parameter' do
      subject.put_credential(new_credential, overwrite: true)
      expect(mock_http_client)
        .to have_received(:put).with('/api/v1/data', new_credential.attributes_for_put.merge(overwrite: true).to_json)
    end

    describe 'additional_permissions parameter' do
      let(:permission_one) do
        CredHubble::Resources::Permission.new(
          actor: 'uaa-user:18f64563-bcfe-4c88-bf73-05c9ad3654c8',
          operations: %w[write delete]
        )
      end
      let(:permission_two) do
        CredHubble::Resources::Permission.new(
          actor: 'uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47',
          operations: %w[write read]
        )
      end
      let(:expected_request_body) do
        JSON.parse('{
          "name": "/load-balancer-tls-cert",
          "type": "certificate",
          "value": {
            "ca": "-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----",
            "certificate": "-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
          },
          "additional_permissions": [
            {
              "actor": "uaa-user:18f64563-bcfe-4c88-bf73-05c9ad3654c8",
              "operations": [
                "write",
                "delete"
              ]
            },
            {
              "actor": "uaa-user:82f8ff1a-fcf8-4221-8d6b-0a1d579b6e47",
              "operations": [
                "write",
                "read"
              ]
            }
          ]
        }').to_json
      end

      it 'works with a PermissionCollection' do
        permissions = CredHubble::Resources::PermissionCollection.new(permissions: [permission_one, permission_two])
        subject.put_credential(new_credential, additional_permissions: permissions)
        expect(mock_http_client).to have_received(:put)
          .with('/api/v1/data', expected_request_body)
      end

      it 'works with a simple array of Permission objects' do
        permissions = [permission_one, permission_two]
        subject.put_credential(new_credential, additional_permissions: permissions)
        expect(mock_http_client).to have_received(:put)
          .with('/api/v1/data', expected_request_body)
      end
    end

    it 'returns a Credential resource' do
      credential = subject.put_credential(new_credential)
      expect(credential).to be_a(CredHubble::Resources::CertificateCredential)
      expect(credential.name).to eq('/load-balancer-tls-cert')
      expect(credential.version_created_at).to eq('1990-01-05T01:01:01Z')
    end
  end

  describe '#interpolate_credentials' do
    let(:vcap_services_json) do
      '{
        "grid-config":[
          {
            "credentials":{
              "credhub-ref":"/grid-config/users/kflynn"
            },
            "label":"grid-config",
            "name":"config-server",
            "plan":"digital-frontier",
            "provider":null,
            "syslog_drain_url":null,
            "tags":[
              "configuration",
              "biodigital-jazz"
            ],
            "volume_mounts":[]
          }
        ],
        "encomSQL":[
          {
            "credentials":{
              "credhub-ref":"/encomSQL/db/users/63f7b900-982f-4f20-9213-6d270c3c58ea"
            },
            "label":"encom-db",
            "name":"encom-enterprise-db",
            "plan":"enterprise",
            "provider":null,
            "syslog_drain_url":null,
            "tags":[
              "database",
              "sql"
            ],
            "volume_mounts":[]
          }
        ]
      }'
    end
    let(:response_body) do
      '{
        "grid-config":[
          {
            "credentials":{
              "username":"kflynn",
              "password":"FlynnLives"
            },
            "label":"grid-config",
            "name":"config-server",
            "plan":"digital-frontier",
            "provider":null,
            "syslog_drain_url":null,
            "tags":[
              "configuration",
              "biodigital-jazz"
            ],
            "volume_mounts":[]
          }
        ],
        "encomSQL":[
          {
            "credentials":{
              "username":"grid-db-user",
              "password":"p4ssw0rd"
            },
            "label":"encom-db",
            "name":"encom-enterprise-db",
            "plan":"enterprise",
            "provider":null,
            "syslog_drain_url":null,
            "tags":[
              "database",
              "sql"
            ],
            "volume_mounts":[]
          }
        ]
      }'
    end

    it 'makes a POST request to the /api/v1/interpolate endpoint with the provided json' do
      subject.interpolate_credentials(vcap_services_json)
      expect(mock_http_client).to have_received(:post).with('/api/v1/interpolate', vcap_services_json)
    end

    it 'returns JSON with credhub-ref credentials populated' do
      expect(subject.interpolate_credentials(vcap_services_json)).to eq(response_body)
    end
  end

  describe '#delete_credential_by_name' do
    let(:response_body) { '' }
    let(:response_status) { 204 }

    it 'makes a DELETE request to the /api/v1/data endpoint with the name as a query parameter' do
      subject.delete_credential_by_name('/outdated-credential')
      expect(mock_http_client).to have_received(:delete).with('/api/v1/data?name=%2Foutdated-credential')
    end

    it 'returns true if the delete request was a success' do
      expect(subject.delete_credential_by_name('/outdated-credential')).to be true
    end
  end
end
