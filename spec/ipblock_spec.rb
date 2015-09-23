require 'spec_helper'

describe ProfitBricks::IPBlock do
  before(:all) do
    @ipblock = ProfitBricks::IPBlock.reserve(options[:ipblock])
  end

  after(:all) do
    @ipblock.release
  end

  # alias: create
  it '#reserve' do
    expect(@ipblock.type).to eq('ipblock')
    expect(@ipblock.id).to match(options[:uuid])
    expect(@ipblock.properties['ips'].count).to be > 0
    expect(@ipblock.properties['location']).to eq('de/fra')
    expect(@ipblock.properties['size']).to eq(1)
  end

  it '#list' do
    ipblocks = ProfitBricks::IPBlock.list

    expect(ipblocks.count).to be > 0
    expect(ipblocks[0].type).to eq('ipblock')
    expect(ipblocks[0].id).to match(options[:uuid])
    expect(ipblocks[0].properties['ips'].count).to be > 0
    expect(ipblocks[0].properties['location']).to eq('de/fra')
    expect(ipblocks[0].properties['size']).to be_kind_of(Integer)
  end

  it '#get' do
    ipblock = ProfitBricks::IPBlock.get(@ipblock.id)

    expect(ipblock.type).to eq('ipblock')
    expect(ipblock.id).to eq(@ipblock.id)
    expect(ipblock.properties['ips'].count).to be > 0
    expect(ipblock.properties['location']).to eq('de/fra')
    expect(ipblock.properties['size']).to eq(1)
  end

  # alias: delete
  it '#release' do
    ipblock = ProfitBricks::IPBlock.reserve(options[:ipblock])

    expect(ipblock.release).to be_kind_of(Hash)
  end
end
