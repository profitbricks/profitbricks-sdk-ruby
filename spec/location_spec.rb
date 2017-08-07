require 'spec_helper'

describe ProfitBricks::Location do
  it '#list' do
    @locations = ProfitBricks::Location.list

    expect(@locations.count).to be > 0
    expect(@locations[0].type).to eq('location')
    expect(@locations[0].id).to match(/^\w+\/\w+$/)
    expect(@locations[0].properties['name']).to be_kind_of(String)
  end

  it '#get' do
    location = ProfitBricks::Location.get('us/las')

    expect(location.type).to eq('location')
    expect(location.id).to match(/^\w+\/\w+$/)
    expect(location.properties['name']).to be_kind_of(String)
    expect(location.properties['imageAliases']).to include('ubuntu:latest')
  end
end
