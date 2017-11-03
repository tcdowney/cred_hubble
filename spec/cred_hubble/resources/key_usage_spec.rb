require 'spec_helper'

RSpec.describe CredHubble::Resources::KeyUsage do
  describe '.from_json' do
    subject { CredHubble::Resources::KeyUsage }

    context 'when the JSON includes the required attributes' do
      let(:json_response) { '{"active_key": 42, "inactive_keys": 2, "unknown_keys": 0}' }

      it 'instantiates a new KeyUsage object with the correct values' do
        key_usage = subject.from_json(json_response)
        expect(key_usage.active_key).to eq(42)
        expect(key_usage.inactive_keys).to eq(2)
        expect(key_usage.unknown_keys).to eq(0)
      end
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::KeyUsage.new(active_key: 117) }

    it_behaves_like 'an immutable resource', :active_key
  end
end
