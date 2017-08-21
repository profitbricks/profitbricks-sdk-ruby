require 'spec_helper'

describe ProfitBricks::Snapshot do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @volume = ProfitBricks::Volume.create(@datacenter.id, options[:volume])
    @volume.wait_for { ready? }

    @snapshot = ProfitBricks::Snapshot.create(@datacenter.id, @volume.id, options[:snapshot])
    @snapshot.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@snapshot.type).to eq('snapshot')
    expect(@snapshot.id).to match(options[:uuid])
    expect(@snapshot.properties['name']).to eq('Ruby SDK Test')
    expect(@snapshot.properties['description']).to eq('Ruby SDK test snapshot')
    expect(@snapshot.properties['location']).to match(/\w+\/\w+/)
    expect(@snapshot.properties['size']).to be nil
    expect(@snapshot.properties['cpuHotPlug']).to be false
    expect(@snapshot.properties['cpuHotUnplug']).to be false
    expect(@snapshot.properties['ramHotPlug']).to be false
    expect(@snapshot.properties['ramHotUnplug']).to be false
    expect(@snapshot.properties['nicHotPlug']).to be false
    expect(@snapshot.properties['nicHotUnplug']).to be false
    expect(@snapshot.properties['discVirtioHotPlug']).to be false
    expect(@snapshot.properties['discVirtioHotUnplug']).to be false
    expect(@snapshot.properties['discScsiHotPlug']).to be false
    expect(@snapshot.properties['discScsiHotUnplug']).to be false
    expect(@snapshot.properties['licenceType']).to be nil
  end

  # it '#create failure' do
  #  expect { ProfitBricks::Snapshot.create(@datacenter.id, @volume.id, description: 'Ruby SDK test snapshot - RENAME') }.to raise_error(Excon::Error::UnprocessableEntity, /Attribute 'name' is required/)
  # end

  it '#list' do
    snapshots = ProfitBricks::Snapshot.list

    expect(snapshots.count).to be > 0
    expect(snapshots[0].type).to eq('snapshot')
    expect(snapshots[0].id).to match(options[:uuid])
    expect(snapshots[0].properties['name']).to be_kind_of(String)
    expect(snapshots[0].properties['description']).to be_kind_of(String)
    expect(snapshots[0].properties['location']).to match(/\w+\/\w+/)
    expect(snapshots[0].properties['size']).to be_kind_of(Integer)
    expect(snapshots[0].properties['cpuHotPlug']).to be false
    expect(snapshots[0].properties['cpuHotUnplug']).to be false
    expect(snapshots[0].properties['ramHotPlug']).to be false
    expect(snapshots[0].properties['ramHotUnplug']).to be false
    expect(snapshots[0].properties['nicHotPlug']).to be false
    expect(snapshots[0].properties['nicHotUnplug']).to be false
    expect(snapshots[0].properties['discVirtioHotPlug']).to be false
    expect(snapshots[0].properties['discVirtioHotUnplug']).to be false
    expect(snapshots[0].properties['discScsiHotPlug']).to be false
    expect(snapshots[0].properties['discScsiHotUnplug']).to be false
    expect(snapshots[0].properties['licenceType']).to be_kind_of(String)
  end

  it '#get' do
    snapshot = ProfitBricks::Snapshot.get(@snapshot.id)

    expect(snapshot.type).to eq('snapshot')
    expect(snapshot.id).to eq(@snapshot.id)
    expect(snapshot.properties['location']).to eq('us/las')
    expect(snapshot.properties['name']).to be_kind_of(String)
    expect(snapshot.properties['description']).to be_kind_of(String)
    expect(snapshot.properties['location']).to match(/\w+\/\w+/)
    expect(snapshot.properties['size']).to be_kind_of(Integer)
    expect(snapshot.properties['cpuHotPlug']).to be false
    expect(snapshot.properties['cpuHotUnplug']).to be false
    expect(snapshot.properties['ramHotPlug']).to be false
    expect(snapshot.properties['ramHotUnplug']).to be false
    expect(snapshot.properties['nicHotPlug']).to be false
    expect(snapshot.properties['nicHotUnplug']).to be false
    expect(snapshot.properties['discVirtioHotPlug']).to be false
    expect(snapshot.properties['discVirtioHotUnplug']).to be false
    expect(snapshot.properties['discScsiHotPlug']).to be false
    expect(snapshot.properties['discScsiHotUnplug']).to be false
    expect(snapshot.properties['licenceType']).to eq('UNKNOWN')

    expect(snapshot.properties['size']).to eq(@volume.properties['size'])
    expect(snapshot.properties['cpuHotPlug']).to eq(@volume.properties['cpuHotPlug'])
    expect(snapshot.properties['cpuHotUnplug']).to eq(@volume.properties['cpuHotUnplug'])
    expect(snapshot.properties['ramHotPlug']).to eq(@volume.properties['ramHotPlug'])
    expect(snapshot.properties['ramHotUnplug']).to eq(@volume.properties['ramHotUnplug'])
    expect(snapshot.properties['nicHotPlug']).to eq(@volume.properties['nicHotPlug'])
    expect(snapshot.properties['nicHotUnplug']).to eq(@volume.properties['nicHotUnplug'])
    expect(snapshot.properties['discVirtioHotPlug']).to eq(@volume.properties['discVirtioHotPlug'])
    expect(snapshot.properties['discVirtioHotUnplug']).to eq(@volume.properties['discVirtioHotUnplug'])
    expect(snapshot.properties['discScsiHotPlug']).to eq(@volume.properties['discScsiHotPlug'])
    expect(snapshot.properties['discScsiHotUnplug']).to eq(@volume.properties['discScsiHotUnplug'])
    expect(snapshot.properties['licenceType']).to eq(@volume.properties['licenceType'])
  end

  it '#get failure' do
    expect { ProfitBricks::Snapshot.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  it '#update' do
    snapshot = @snapshot.update({ name: 'Ruby SDK Test - RENAME', description: 'Ruby SDK test snapshot - RENAME' })
    snapshot.wait_for { ready? }

    expect(snapshot.type).to eq('snapshot')
    expect(snapshot.id).to match(options[:uuid])
    expect(snapshot.properties['name']).to eq('Ruby SDK Test - RENAME')
    expect(snapshot.properties['description']).to eq('Ruby SDK test snapshot - RENAME')
    expect(snapshot.properties['description']).to be_kind_of(String)
    expect(snapshot.properties['location']).to match(/\w+\/\w+/)
    expect(snapshot.properties['size']).to be_kind_of(Integer)
    expect(snapshot.properties['cpuHotPlug']).to be false
    expect(snapshot.properties['cpuHotUnplug']).to be false
    expect(snapshot.properties['ramHotPlug']).to be false
    expect(snapshot.properties['ramHotUnplug']).to be false
    expect(snapshot.properties['nicHotPlug']).to be false
    expect(snapshot.properties['nicHotUnplug']).to be false
    expect(snapshot.properties['discVirtioHotPlug']).to be false
    expect(snapshot.properties['discVirtioHotUnplug']).to be false
    expect(snapshot.properties['discScsiHotPlug']).to be false
    expect(snapshot.properties['discScsiHotUnplug']).to be false
    expect(snapshot.properties['licenceType']).to eq('UNKNOWN')
  end

  it '#delete' do
    snapshot = @volume.create_snapshot(options[:snapshot])
    snapshot.wait_for { ready? }

    snapshot = snapshot.delete
    expect(snapshot.type).to eq('snapshot')
    expect(snapshot.delete.requestId).to match(options[:uuid])
  end
end
