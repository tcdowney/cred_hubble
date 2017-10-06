require 'spec_helper'

RSpec.shared_examples 'a request with error handling' do
  context 'when the response status is 400' do
    let(:response_body) { 'Bad request' }
    let(:status) { 400 }

    it 'raises a CredHubble::Http::BadRequestError' do
      expect { subject }
        .to raise_error(CredHubble::Http::BadRequestError, "status: #{status}, body: #{response_body}")
    end
  end

  context 'when the response status is 401' do
    let(:response_body) { 'Unauthorized' }
    let(:status) { 401 }

    it 'raises a CredHubble::Http::UnauthorizedError' do
      expect { subject }
        .to raise_error(CredHubble::Http::UnauthorizedError, "status: #{status}, body: #{response_body}")
    end
  end

  context 'when the response status is 403' do
    let(:response_body) { 'Forbidden' }
    let(:status) { 403 }

    it 'raises a CredHubble::Http::ForbiddenError' do
      expect { subject }
        .to raise_error(CredHubble::Http::ForbiddenError, "status: #{status}, body: #{response_body}")
    end
  end

  context 'when the response status is 404' do
    let(:response_body) { 'Not found' }
    let(:status) { 404 }

    it 'raises a CredHubble::Http::NotFoundError' do
      expect { subject }
        .to raise_error(CredHubble::Http::NotFoundError, "status: #{status}, body: #{response_body}")
    end
  end

  context 'when the response status is 500' do
    let(:response_body) { 'Internal Server Error' }
    let(:status) { 500 }

    it 'raises a CredHubble::Http::InternalServerError' do
      expect { subject }
        .to raise_error(CredHubble::Http::InternalServerError, "status: #{status}, body: #{response_body}")
    end
  end

  context 'when the response status is not otherwise handled' do
    let(:response_body) { "I'm a teapot" }
    let(:status) { 418 }

    it 'raises a CredHubble::Http::InternalServerError' do
      expect { subject }
        .to raise_error(CredHubble::Http::UnknownError, "status: #{status}, body: #{response_body}")
    end
  end
end

RSpec.describe CredHubble::Http::Client do
  let(:url) { 'https://example.com:8845' }
  subject { CredHubble::Http::Client.new(url) }

  describe '#get' do
    let(:path) { '/info' }
    let(:status) { 200 }
    let(:response_body) do
      '{
        "auth-server": {
          "url":"https:/some-uaa-auth-server.com:8443"
        },
        "app": {
          "name":"CredHub 3000",
          "version":"0.0.1"
        }
       }'
    end

    before do
      stub_request(:get, "#{url}#{path}").to_return(status: status, body: response_body)
    end

    it 'makes a GET request to the requested url and path' do
      response = subject.get(path)
      expect(response).to be_a(Faraday::Response)
      expect(response.body).to eq(response_body)
      expect(response.status).to eq(status)
    end

    describe 'error handling' do
      subject { CredHubble::Http::Client.new(url).get(path) }

      context 'when a Faraday::SSLError occurrs' do
        let(:error) { Faraday::SSLError.new('SSL_connect returned=1 errno=0 state=error: certificate verify failed') }
        let(:fake_connection) { instance_double(Faraday::Connection) }

        before do
          allow_any_instance_of(CredHubble::Http::Client).to receive(:connection).and_return(fake_connection)
          allow(fake_connection).to receive(:get).and_raise(error)
        end

        it 'raises a CredHubble::Exceptions::SSLError' do
          expect { subject }.to raise_error(CredHubble::Http::SSLError)
        end
      end

      it_behaves_like 'a request with error handling'
    end

    describe 'request headers' do
      context 'when client is initialized with an auth_token_header' do
        let(:token) { 'meesa-jar-jar-binks-token' }
        subject { CredHubble::Http::Client.new(url, auth_header_token: token) }

        it 'includes an Authorization header with the provided bearer token' do
          subject.get(path)
          assert_requested(
            :get,
            "#{url}#{path}",
            headers: { 'Content-Type' => 'application/json', 'Authorization' => "bearer #{token}" }
          )
        end
      end

      context 'when client is not initialized with an auth_token_header' do
        subject { CredHubble::Http::Client.new(url) }

        it 'does not include an authorization header' do
          subject.get(path)
          assert_requested(:get, "#{url}#{path}", headers: { 'Content-Type' => 'application/json' })
        end
      end
    end
  end

  describe '#put' do
    let(:path) { '/api/v1/data' }
    let(:status) { 200 }
    let(:request_body) do
      '{
        "name": "/la-la-land",
        "type": "value",
        "value": "another day of sun: purple shirt parkour"
      }'
    end
    let(:response_body) do
      '{
        "id": "62630719-2413-4332-9e39-a8acbd73d3b7",
        "name": "/la-la-land",
        "type": "value",
        "value": "another day of sun: purple shirt parkour",
        "version_created_at": "2017-01-01T04:07:18Z"
      }'
    end

    before do
      stub_request(:put, "#{url}#{path}").with(body: request_body).to_return(status: status, body: response_body)
    end

    it 'makes a PUT request with the given body to the requested url and path' do
      response = subject.put(path, request_body)
      expect(response).to be_a(Faraday::Response)
      expect(response.body).to eq(response_body)
      expect(response.status).to eq(status)
    end

    describe 'error handling' do
      subject { CredHubble::Http::Client.new(url).put(path, request_body) }

      context 'when a Faraday::SSLError occurrs' do
        let(:error) { Faraday::SSLError.new('SSL_connect returned=1 errno=0 state=error: certificate verify failed') }
        let(:fake_connection) { instance_double(Faraday::Connection) }

        before do
          allow_any_instance_of(CredHubble::Http::Client).to receive(:connection).and_return(fake_connection)
          allow(fake_connection).to receive(:put).and_raise(error)
        end

        it 'raises a CredHubble::Exceptions::SSLError' do
          expect { subject }.to raise_error(CredHubble::Http::SSLError)
        end
      end

      it_behaves_like 'a request with error handling'
    end

    describe 'request headers' do
      context 'when client is initialized with an auth_token_header' do
        let(:token) { 'meesa-jar-jar-binks-token' }
        subject { CredHubble::Http::Client.new(url, auth_header_token: token) }

        it 'includes an Authorization header with the provided bearer token' do
          subject.put(path, request_body)
          assert_requested(
            :put,
            "#{url}#{path}",
            body: request_body,
            headers: { 'Content-Type' => 'application/json', 'Authorization' => "bearer #{token}" }
          )
        end
      end

      context 'when client is not initialized with an auth_token_header' do
        subject { CredHubble::Http::Client.new(url) }

        it 'does not include an authorization header' do
          subject.put(path, request_body)
          assert_requested(
            :put,
            "#{url}#{path}",
            body: request_body,
            headers: { 'Content-Type' => 'application/json' }
          )
        end
      end
    end
  end

  describe 'SSL/TLS configuration' do
    subject { CredHubble::Http::Client.new(url) }

    it 'has ssl verification enabled' do
      connection = subject.send(:connection)
      expect(connection.ssl.verify).to eq(true)
    end

    context 'when a file path is not provided for the CredHub CA' do
      subject { CredHubble::Http::Client.new(url) }

      it 'does not include any additional CA certs' do
        connection = subject.send(:connection)
        expect(connection.ssl.ca_file).to be_nil
      end
    end

    context 'when a file path is provided for the CredHub CA' do
      let(:credhub_ca_path) { '/custom/certstore/credhub_ca.crt' }
      subject { CredHubble::Http::Client.new(url, credhub_ca_path: credhub_ca_path) }

      it 'includes the CA cert file path in the connection ssl config' do
        connection = subject.send(:connection)
        expect(connection.ssl.ca_file).to eq(credhub_ca_path)
      end
    end

    describe 'mutual TLS client cert and client key' do
      let(:mock_cert) { instance_double(OpenSSL::X509::Certificate) }
      let(:mock_key) { instance_double(OpenSSL::PKey::RSA) }

      context 'when a client cert and client key are not provided' do
        subject { CredHubble::Http::Client.new(url) }

        it 'does not include any client cert or client key' do
          connection = subject.send(:connection)
          expect(connection.ssl.client_cert).to be_nil
          expect(connection.ssl.client_key).to be_nil
        end
      end

      context 'when a client cert and client key are provided for the CredHub CA' do
        let(:credhub_ca_path) { '/custom/certstore/credhub_ca.crt' }
        subject { CredHubble::Http::Client.new(url, client_cert: mock_cert, client_key: mock_key) }

        it 'includes the cert file in the connection ssl config' do
          connection = subject.send(:connection)
          expect(connection.ssl.client_cert).to eq(mock_cert)
          expect(connection.ssl.client_key).to eq(mock_key)
        end
      end
    end
  end
end
