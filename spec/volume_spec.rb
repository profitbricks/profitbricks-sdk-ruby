require 'spec_helper'

describe ProfitBricks::Volume do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @volume = ProfitBricks::Volume.create(@datacenter.id, options[:volume])
    @volume.wait_for { ready? }

    @volume.attach(@server.id)
    @volume.wait_for { ready? }

    @snapshot = @volume.create_snapshot(options[:snapshot])
    @snapshot.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@volume.type).to eq('volume')
    expect(@volume.id).to match(options[:uuid])
    expect(@volume.properties['name']).to eq('my boot volume for server 1')
    expect(@volume.properties['size']).to be_kind_of(Integer)
    expect(@volume.properties['bus']).to be nil
    expect(@volume.properties['type']).to be nil
  end

  it '#list' do
    volumes = ProfitBricks::Volume.list(@datacenter.id)

    expect(volumes.count).to be > 0
    expect(volumes[0].type).to eq('volume')
    expect(volumes[0].id).to eq(@volume.id)
    expect(volumes[0].properties['name']).to eq('my boot volume for server 1')
    expect(volumes[0].properties['size']).to be_kind_of(Integer)
    expect(volumes[0].properties['bus']).to eq('VIRTIO')
    expect(volumes[0].properties['type']).to eq('HDD')
  end

  it '#get' do
    volume = ProfitBricks::Volume.get(@datacenter.id, @volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.id).to eq(@volume.id)
    expect(volume.properties['name']).to eq('my boot volume for server 1')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
    expect(volume.properties['type']).to eq('HDD')
  end

  it '#update' do
    volume = @volume.update(
      name: 'Resized storage to 15 GB',
      size: 15
    )

    expect(volume.type).to eq('volume')
    expect(volume.id).to eq(@volume.id)
    expect(volume.properties['name']).to eq('Resized storage to 15 GB')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
    expect(volume.properties['type']).to eq('HDD')
  end

  it '#delete' do
    volume = ProfitBricks::Volume.create(@datacenter.id, options[:volume])
    volume.wait_for { ready? }

    expect(volume.delete.requestId).to match(options[:uuid])
  end

  it '#attach' do
    volume = @volume.attach(@server.id)

    expect(volume.type).to eq('volume')
    expect(volume.id).to eq(@volume.id)
    expect(volume.properties['name']).to be_kind_of(String)
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
    expect(volume.properties['type']).to eq('HDD')
  end

  it '#detach' do
    volume = @volume.detach(@server.id)

    expect(volume).to be_kind_of(Hash)
  end

  it '#create_snapshop' do
    # Confirm snapshot has been created.
    expect(@snapshot.type).to eq('snapshot')
    expect(@snapshot.properties['name']).to eq('Snapshot of storage X on 12.12.12 12:12:12 - updated')
    expect(@snapshot.properties['description']).to eq('description of a snapshot - updated')
  end

  it '#restore_snapshot' do
    expect(@volume.restore_snapshot(@snapshot.id)).to have_key(:requestId)
  end
end
