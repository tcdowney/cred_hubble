require 'spec_helper'

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

    context 'when a Faraday::SSLError occurrs' do
      let(:error) { Faraday::SSLError.new('SSL_connect returned=1 errno=0 state=error: certificate verify failed') }
      let(:fake_connection) { instance_double(Faraday::Connection) }

      before do
        allow(subject).to receive(:connection).and_return(fake_connection)
        allow(fake_connection).to receive(:get).and_raise(error)
      end

      it 'raises a CredHubble::Exceptions::SSLError' do
        expect { subject.get(path) }.to raise_error(CredHubble::Http::SSLError)
      end
    end

    context 'when the response status is 400' do
      let(:response_body) { 'Bad request' }
      let(:status) { 400 }

      it 'raises a CredHubble::Http::BadRequestError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::BadRequestError, "status: #{status}, body: #{response_body}")
      end
    end

    context 'when the response status is 401' do
      let(:response_body) { 'Unauthorized' }
      let(:status) { 401 }

      it 'raises a CredHubble::Http::UnauthorizedError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::UnauthorizedError, "status: #{status}, body: #{response_body}")
      end
    end

    context 'when the response status is 403' do
      let(:response_body) { 'Forbidden' }
      let(:status) { 403 }

      it 'raises a CredHubble::Http::ForbiddenError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::ForbiddenError, "status: #{status}, body: #{response_body}")
      end
    end

    context 'when the response status is 404' do
      let(:response_body) { 'Not found' }
      let(:status) { 404 }

      it 'raises a CredHubble::Http::NotFoundError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::NotFoundError, "status: #{status}, body: #{response_body}")
      end
    end

    context 'when the response status is 500' do
      let(:response_body) { 'Internal Server Error' }
      let(:status) { 500 }

      it 'raises a CredHubble::Http::InternalServerError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::InternalServerError, "status: #{status}, body: #{response_body}")
      end
    end

    context 'when the response status is not otherwise handled' do
      let(:response_body) { "I'm a teapot" }
      let(:status) { 418 }

      it 'raises a CredHubble::Http::InternalServerError' do
        expect { subject.get(path) }
          .to raise_error(CredHubble::Http::UnknownError, "status: #{status}, body: #{response_body}")
      end
    end

    describe 'request headers' do
      let(:path) { '/api/v1/data/some-credential-id' }
      let(:status) { 200 }
      let(:response_body) do
        '{
          "id": "cdbb371a-cc03-4a6f-aa21-c6461d66ed96",
          "name": "/real-secret-stuff",
          "type": "password",
          "value": "06d23797cdee41a8857627f31c430ba",
          "version_created_at": "1990-01-01T01:01:01Z"
        }'
      end

      before do
        stub_request(:get, "#{url}#{path}").to_return(status: status, body: response_body)
      end

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

      context 'when client is initialized with an auth_token_header' do
        subject { CredHubble::Http::Client.new(url) }

        it 'does not include an authorization header' do
          subject.get(path)
          assert_requested(:get, "#{url}#{path}", headers: { 'Content-Type' => 'application/json' })
        end
      end
    end
  end

  describe 'SSL verification' do
    context 'when verify_ssl is not specified' do
      subject { CredHubble::Http::Client.new(url) }

      it 'has ssl verification enabled' do
        connection = subject.send(:connection)
        expect(connection.ssl.verify).to eq(true)
      end
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

      it 'includes the cert file in the connection ssl config' do
        connection = subject.send(:connection)
        expect(connection.ssl.ca_file).to eq(credhub_ca_path)
      end
    end
  end
end
