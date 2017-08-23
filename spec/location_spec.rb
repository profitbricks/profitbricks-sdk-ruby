require 'spec_helper'

describe ProfitBricks::Location do
  it '#list' do
    @locations = ProfitBricks::Location.list

    expect(@locations.count).to be > 0
    expect(@locations[0].type).to eq('location')
    expect(@locations[0].id).to match(/^\w+\/\w+$/)
    expect(@locations[0].properties['name']).to be_kind_of(String)
    expect(@locations.find { |item| item.id == 'us/las' }).to_not be_nil
  end

  it '#get' do
    location = ProfitBricks::Location.get('us/las')

    expect(location.id).to eq('us/las')
    expect(location.type).to eq('location')
    expect(location.id).to match(/^\w+\/\w+$/)
    expect(location.properties['name']).to be_kind_of(String)
  end

  it '#get failure' do
    expect { ProfitBricks::Location.get("us/aa") }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end
end
