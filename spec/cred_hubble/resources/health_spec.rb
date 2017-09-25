require 'spec_helper'

RSpec.describe CredHubble::Resources::Health do
  describe '.from_json' do
    subject { CredHubble::Resources::Health }

    context 'when the JSON includes the required attributes' do
      let(:json_response) { '{"status": "UP"}' }

      it 'instantiates a new Health object with the correct values' do
        health = subject.from_json(json_response)
        expect(health.status).to eq('UP')
      end
    end

    it_behaves_like 'a JSON deserializing resource'
  end

  describe 'immutability' do
    subject { CredHubble::Resources::Health.new(status: 'UP') }

    it_behaves_like 'an immutable resource', :status
  end
end
