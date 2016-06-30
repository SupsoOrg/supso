require 'spec_helper'

describe Supso do
  it 'has the right version' do
    expect(Supso::VERSION).to eq('0.9.2')
  end

  it 'has the right api endpoint' do
    expect(Supso.supso_api_root).to eq('https://supportedsource.org/api/v1/')
  end
end
