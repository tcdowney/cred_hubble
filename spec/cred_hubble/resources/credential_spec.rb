require 'spec_helper'

RSpec.describe CredHubble::Resources::Credential do
  describe '.from_json' do
    subject { CredHubble::Resources::Credential }

    it_behaves_like 'a Credential resource'
    it_behaves_like 'a JSON deserializing resource'
  end
end
