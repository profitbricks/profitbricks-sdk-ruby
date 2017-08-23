require 'spec_helper'

describe ProfitBricks::Volume do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @volume_with_alias = ProfitBricks::Volume.create(@datacenter.id,options[:volume_with_alias])
    @volume_with_alias.wait_for { ready? }

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

  it '#create failure' do
    expect { ProfitBricks::Volume.create(@datacenter.id, name: 'Ruby SDK Test') }.to raise_error(Excon::Error::UnprocessableEntity, /Attribute 'size' is required/)
  end

  it '#create' do
    expect(@volume.type).to eq('volume')
    expect(@volume.id).to match(options[:uuid])
    expect(@volume.properties['name']).to eq('Ruby SDK Test')
    expect(@volume.properties['size']).to be_kind_of(Integer)
    expect(@volume.properties['bus']).to eq('VIRTIO')
    expect(@volume.properties['size']).to eq(2)
    expect(@volume.properties['type']).to eq('HDD')
    expect(@volume.properties['licenceType']).to eq('UNKNOWN')
    expect(@volume.properties['availabilityZone']).to eq('ZONE_3')
    #expect(@volume.properties['sshKeys']).to be_kind_of(Array)
  end

  it '#create image alias' do
    expect(@volume_with_alias.type).to eq('volume')
    expect(@volume_with_alias.properties['name']).to eq('volume created with alias')
    expect(@volume_with_alias.properties['size']).to be_kind_of(Integer)
    expect(@volume_with_alias.properties['bus']).to be nil
    expect(@volume_with_alias.properties['type']).to eq('HDD')
    expect(@volume_with_alias.properties['imagePassword']).to eq('Vol44lias')
  end

  it '#list' do
    volumes = ProfitBricks::Volume.list(@datacenter.id)

    expect(volumes.count).to be > 0
    expect(volumes[0].type).to eq('volume')
    expect(volumes[0].id).to eq(@volume.id)
    expect(volumes[0].properties['name']).to eq('Ruby SDK Test')
    expect(volumes[0].properties['size']).to be_kind_of(Integer)
    expect(volumes[0].properties['bus']).to eq('VIRTIO')
    expect(volumes[0].properties['type']).to eq('HDD')
  end

  it '#get' do
    volume = ProfitBricks::Volume.get(@datacenter.id, @volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.id).to eq(@volume.id)
    expect(volume.properties['name']).to eq('Ruby SDK Test')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['size']).to eq(2)
    expect(volume.properties['bus']).to eq('VIRTIO')
    expect(volume.properties['type']).to eq('HDD')
    expect(volume.properties['licenceType']).to eq('UNKNOWN')
    expect(volume.properties['availabilityZone']).to eq('ZONE_3')
    #expect(volume.properties['sshKeys']).to be_kind_of(Array)
  end

  it '#get failure' do
      expect { ProfitBricks::Volume.get(@datacenter.id,options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  it '#update' do
    volume = @volume.update(
      name: 'Ruby SDK Test - RENAME',
      size: 5
    )

    expect(volume.type).to eq('volume')
    expect(volume.id).to eq(@volume.id)
    expect(volume.properties['name']).to eq('Ruby SDK Test - RENAME')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
    expect(volume.properties['type']).to eq('HDD')
    expect(volume.properties['size']).to eq(5)
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

  it '#create_snapshot' do
    # Confirm snapshot has been created.
    expect(@snapshot.type).to eq('snapshot')
    expect(@snapshot.properties['name']).to eq('Ruby SDK Test')
    expect(@snapshot.properties['description']).to eq('Ruby SDK test snapshot')
  end

  it '#restore_snapshot' do
    expect(@volume.restore_snapshot(@snapshot.id)).to have_key(:requestId)
  end
end
