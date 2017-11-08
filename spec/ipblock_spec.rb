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
    expect(@ipblock.properties['name']).to eq('Ruby SDK Test')
    expect(@ipblock.properties['location']).to eq('us/las')
    expect(@ipblock.properties['size']).to eq(2)
  end

  it '#reserve failure' do
    expect { ProfitBricks::IPBlock.reserve({ name: 'Ruby SDK Test', size: '1' }) }.to raise_error(Excon::Error::UnprocessableEntity, /Attribute 'location' is required/)
  end

  it '#list' do
    ipblocks = ProfitBricks::IPBlock.list

    expect(ipblocks.count).to be > 0
    expect(ipblocks[0].type).to eq('ipblock')
    expect(ipblocks[0].id).to match(options[:uuid])
    expect(ipblocks[0].properties['ips'].count).to be > 0
    expect(ipblocks[0].properties['location']).to eq('us/las')
    expect(ipblocks[0].properties['size']).to be_kind_of(Integer)
  end

  it '#get' do
    ipblock = ProfitBricks::IPBlock.get(@ipblock.id)

    expect(ipblock.type).to eq('ipblock')
    expect(ipblock.id).to eq(@ipblock.id)
    expect(ipblock.properties['ips'].count).to eq(2)
    expect(ipblock.properties['name']).to eq('Ruby SDK Test')
    expect(ipblock.properties['location']).to eq('us/las')
    expect(ipblock.properties['size']).to eq(2)
  end

  it '#get failure' do
      expect { ProfitBricks::IPBlock.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  # alias: delete
  it '#release' do
    opts = options[:ipblock]
    opts[:size] = 1
    ipblock = ProfitBricks::IPBlock.reserve(opts)

    expect(ipblock.release).to be_kind_of(Hash)
  end
end
