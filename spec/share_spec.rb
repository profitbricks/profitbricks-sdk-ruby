require 'spec_helper'

describe ProfitBricks::Share do
  before(:all) do

    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @group = ProfitBricks::Group.create(options[:group])
    @group.wait_for { ready? }

    @share = ProfitBricks::Share.create(@group.id, @datacenter.id, options[:share])
    @share.wait_for { ready? }
  end

  after(:all) do
    @group.delete()
    @datacenter.delete
  end

  it '#create failure' do
   expect { ProfitBricks::Share.create(@group.id, options[:bad_id], {}) }.to raise_error(Excon::Error::NotFound)
  end

  it '#create' do
    expect(@share.type).to eq('resource')
    expect(@share.properties['editPrivilege']).to be true
    expect(@share.properties['sharePrivilege']).to be true
  end

  it '#list' do
    shares = ProfitBricks::Share.list(@group.id)

    expect(shares.count).to be > 0
    expect(shares[0].type).to eq('resource')
  end

  it '#get' do
    share = ProfitBricks::Share.get(@group.id,@datacenter.id)
    expect(share.id).to match(options[:uuid])
    expect(share.type).to eq('resource')
    expect(share.properties['editPrivilege']).to be true
    expect(share.properties['sharePrivilege']).to be true
  end

  it '#get failure' do
    expect { ProfitBricks::Share.get(@group.id, options[:bad_id]) }.to raise_error(Excon::Error::NotFound)
  end

  it '#update' do
    share = ProfitBricks::Share.update(@group.id,@datacenter.id,{
      editPrivilege: false
    })

    expect(share.type).to eq('resource')
    expect(share.properties['editPrivilege']).to be false
  end

  it '#delete' do
    expect(ProfitBricks::Share.delete(@group.id,@datacenter.id)).to be true
  end
end
