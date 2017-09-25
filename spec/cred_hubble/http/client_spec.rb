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
  end

  describe 'SSL verification' do
    context 'when verify_ssl is not specified' do
      subject { CredHubble::Http::Client.new(url) }

      it 'has ssl verification enabled by default' do
        connection = subject.send(:connection)
        expect(connection.ssl.verify).to eq(true)
      end
    end

    # TODO: Remove ability to disable ssl verification
    context 'when verify_ssl is set to false' do
      subject { CredHubble::Http::Client.new(url, verify_ssl: false) }

      it 'has ssl verification disabled' do
        connection = subject.send(:connection)
        expect(connection.ssl.verify).to eq(false)
      end
    end
  end
end
