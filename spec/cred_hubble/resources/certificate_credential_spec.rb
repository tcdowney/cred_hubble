require 'spec_helper'

RSpec.describe CredHubble::Resources::CertificateCredential do
  let(:json_response) do
    '{
        "id": "15811465-8538-460d-9682-5514d44439fd",
        "name": "/load-balancer-tls-cert",
        "type": "certificate",
        "value": {
          "ca": "-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----",
          "certificate": "-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----",
          "private_key": "-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----"
        },
        "version_created_at": "1990-05-18T01:01:01Z"
      }'
  end

  describe '.from_json' do
    subject { CredHubble::Resources::CertificateCredential }

    context 'when the JSON includes the required attributes' do
      it 'instantiates a new CertificateCredential object' do
        credential = subject.from_json(json_response)

        expect(credential).to be_a(CredHubble::Resources::CertificateCredential)
        expect(credential.value.ca)
          .to eq("-----BEGIN CERTIFICATE-----\n... CA CERT ...\n-----END CERTIFICATE-----")
        expect(credential.value.certificate)
          .to eq("-----BEGIN CERTIFICATE-----\n... CERTIFICATE ...\n-----END CERTIFICATE-----")
        expect(credential.value.private_key)
          .to eq("-----BEGIN RSA PRIVATE KEY-----\n... RSA PRIVATE KEY ...\n-----END RSA PRIVATE KEY-----")
      end
    end

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end

  describe '#type' do
    it 'returns "certificate"' do
      subject.type = 'attempting-to-overwrite'
      expect(subject.type).to eq('certificate')
    end
  end

  describe '#to_json' do
    it_behaves_like 'a JSON serializing resource'
  end
end
