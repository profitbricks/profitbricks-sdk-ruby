require 'spec_helper'

describe ProfitBricks::Group do
  before(:all) do
    @group = ProfitBricks::Group.create(options[:group])
    @group.wait_for { ready? }
  end

  after(:all) do
    @group.delete()
  end

  it '#create failure' do
   expect { ProfitBricks::Group.create(options[:bad_group]) }.to raise_error(Excon::Error::UnprocessableEntity)
  end

  it '#create' do
    expect(@group.id).to match(options[:uuid])
    expect(@group.type).to eq('group')
    expect(@group.properties['name']).to eq('Ruby SDK Test')
    expect(@group.properties['createDataCenter']).to be true
    expect(@group.properties['createSnapshot']).to be true
    expect(@group.properties['reserveIp']).to be true
    expect(@group.properties['accessActivityLog']).to be true
  end

  it '#list' do
    groups = ProfitBricks::Group.list()

    expect(groups.count).to be > 0
    expect(groups[0].type).to eq('group')
  end

  it '#get' do
    group = ProfitBricks::Group.get(@group.id)
    expect(@group.type).to eq('group')
    expect(@group.properties['name']).to eq('Ruby SDK Test')
    expect(@group.properties['createDataCenter']).to be true
    expect(@group.properties['createSnapshot']).to be true
    expect(@group.properties['reserveIp']).to be true
    expect(@group.properties['accessActivityLog']).to be true
  end

  it '#get failure' do
    expect { ProfitBricks::Group.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound)
  end

  it '#update' do
    group = @group.update(
      name: 'Ruby SDK Test - RENAME',
      createDataCenter: false
    )

    expect(@group.type).to eq('group')
    expect(@group.properties['name']).to eq('Ruby SDK Test - RENAME')
    expect(@group.properties['createDataCenter']).to be false
  end

  it '#delete' do
    group = ProfitBricks::Group.create(options[:group])
    group.wait_for { ready? }

    expect(group.delete.requestId).to match(options[:uuid])
  end
end
