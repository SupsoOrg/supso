require 'spec_helper'

describe Supso do
  it 'has the right version' do
    expect(Supso::VERSION).to eq('0.10.1')
  end

  it 'has the right api endpoint' do
    expect(Supso.supso_api_root).to eq('https://supso.org/api/v1/')
  end
end
