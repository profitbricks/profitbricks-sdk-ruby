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
    expect(@snapshot.properties['name']).to eq('Snapshot of storage X on 12.12.12 12:12:12 - updated')
    expect(@snapshot.properties['description']).to eq('description of a snapshot - updated')
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
  end

  it '#update' do
    snapshot = @snapshot.update(name: 'New name')
    snapshot.wait_for { ready? }

    expect(snapshot.type).to eq('snapshot')
    expect(snapshot.id).to match(options[:uuid])
    expect(snapshot.properties['name']).to eq('New name')
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

    expect(snapshot.delete).to have_key(:requestId)
  end
end
