require 'spec_helper'

describe ProfitBricks::Server do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @nic = @server.create_nic(options[:nic])
    @nic.wait_for { ready? }

    @volume = ProfitBricks::Volume.create(@datacenter.id, options[:volume])
    @volume.wait_for { ready? }
    @volume.attach(@server.id)

    @image = get_test_image('CDROM')
    @server.attach_cdrom(@image.id)
    @server.wait_for { ready? }

    @composite_server = ProfitBricks::Server.create(
        @datacenter.id,
        options[:composite_server]
    )
  end

  before do
    @server.wait_for { ready? }
    @server.reload
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@server.type).to eq('server')
    expect(@server.id).to match(options[:uuid])
    expect(@server.properties['name']).to eq('New Server')
    expect(@server.properties['cores']).to eq(1)
    expect(@server.properties['ram']).to eq(1024)
    expect(@server.properties['availabilityZone']).to eq('AUTO')
    expect(@server.properties['vmState']).to eq('SHUTOFF').or eq('RUNNING')
  end

  it '#create composite' do
    @composite_server.wait_for(300) { ready? }
    @composite_server.reload
    expect(@composite_server.type).to eq('server')
    expect(@composite_server.id).to match(options[:uuid])
    expect(@composite_server.properties['name']).to eq('New Composite Server')
    expect(@composite_server.properties['cores']).to eq(1)
    expect(@composite_server.properties['ram']).to eq(1024)
    expect(@composite_server.properties['availabilityZone']).to eq('AUTO')
    expect(@composite_server.properties['vmState']).to eq('RUNNING')
    expect(@composite_server.entities['volumes']['items'].count).to be > 0
    expect(@composite_server.entities['nics']['items'].count).to be > 0
  end

  it '#list' do
    servers = ProfitBricks::Server.list(@datacenter.id)

    expect(servers.count).to be > 0
    expect(servers[0].type).to eq('server')
    # expect(servers[0].id).to eq(@server.id)
    # expect(servers[0].properties['name']).to eq('New Server')
    expect(servers[0].properties['cores']).to eq(1)
    expect(servers[0].properties['ram']).to eq(1024)
    expect(servers[0].properties['availabilityZone']).to eq('AUTO')
    expect(servers[0].properties['vmState']).to eq('RUNNING')
    expect(servers[0].properties['bootVolume']['type']).to eq('volume')
    expect(servers[0].properties['bootVolume']['id']).to match(options[:uuid])
    expect(servers[0].properties['bootCdrom']).to be nil
  end

  it '#get' do
    server = ProfitBricks::Server.get(@datacenter.id, @server.id)

    expect(server.type).to eq('server')
    expect(server.id).to eq(@server.id)
    expect(server.properties['name']).to eq('New Server')
    expect(server.properties['cores']).to eq(1)
    expect(server.properties['ram']).to eq(1024)
    expect(server.properties['availabilityZone']).to eq('AUTO')
    expect(server.properties['vmState']).to eq('RUNNING')
    expect(server.properties['bootVolume']['type']).to eq('volume')
    expect(server.properties['bootVolume']['id']).to match(options[:uuid])
    expect(server.properties['bootCdrom']).to be nil
  end

  it '#update' do
    server = @server.update(
        name: 'New Server - Updated',
        cores: 2
    )

    expect(server.id).to eq(@server.id)
    expect(server.properties['name']).to eq('New Server - Updated')
    expect(server.properties['cores']).to eq(2)
    expect(server.properties['ram']).to eq(1024)
    expect(server.properties['availabilityZone']).to eq('AUTO')
    expect(server.properties['vmState']).to eq('RUNNING')
    expect(server.properties['bootVolume']['type']).to eq('volume')
    expect(server.properties['bootVolume']['id']).to match(options[:uuid])
    expect(server.properties['bootCdrom']).to be nil
  end

  it '#delete' do
    server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    server.wait_for { ready? }

    expect(server.delete.requestId).to match(options[:uuid])
    expect(server.wait_for { ready? }).to be_kind_of(Hash)
  end

  it '#stop, reboot, start' do
    expect(@server.stop)
    expect(@server.wait_for { ready? }).to be_kind_of(Hash)
    expect(@server.reboot)
    expect(@server.wait_for { ready? }).to be_kind_of(Hash)
    expect(@server.start)
    expect(@server.wait_for { ready? }).to be_kind_of(Hash)
  end

  it '#list_volumes' do
    volumes = @server.list_volumes

    expect(volumes.count).to be > 0
    expect(volumes[0].type).to eq('volume')
    expect(volumes[0].properties['name']).to eq('my boot volume for server 1')
    expect(volumes[0].properties['size']).to be_kind_of(Integer)
    expect(volumes[0].properties['bus']).to eq('VIRTIO')
  end

  it '#get_volume' do
    volume = @server.get_volume(@volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.properties['name']).to eq('my boot volume for server 1')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
  end

  it '#attach_volume' do
    volume = @server.attach_volume(@volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.properties['name']).to eq('my boot volume for server 1')
    expect(volume.properties['size']).to be_kind_of(Integer)
    expect(volume.properties['bus']).to eq('VIRTIO')
  end

  it '#detach_volume' do
    volume = @server.detach_volume(@volume.id)

    expect(volume).to be_kind_of(Hash)
  end

  it '#list_cdroms' do
    cdroms = @server.list_cdroms

    expect(cdroms.count).to be > 0
    expect(cdroms[0].type).to eq('image')
    expect(cdroms[0].properties['name']).to eq(@image.properties['name'])
    expect(cdroms[0].properties['size']).to be_kind_of(Float)
  end

  it '#get_cdrom' do
    cdrom = @server.get_cdrom(@image.id)

    expect(cdrom.type).to eq('image')
    expect(cdrom.properties['name']).to eq(@image.properties['name'])
    expect(cdrom.properties['size']).to be_kind_of(Float)
  end

  it '#attach_cdrom, detach_cdrom' do
    # Detach existing image
    @server.detach_cdrom(@image.id)
    @server.wait_for { ready? }

    # Attach image
    image = @server.attach_cdrom(@image.id)
    @server.wait_for { ready? }

    expect(image.type).to eq('image')
    expect(image.properties['name']).to be_kind_of(String)
    expect(image.properties['size']).to be_kind_of(Float)
  end

  it '#detach_cdrom' do
    @server.attach_cdrom(@image.id)
    @server.wait_for { ready? }

    cdrom = @server.detach_cdrom(@image.id)
    @server.wait_for { ready? }

    expect(cdrom).to be_kind_of(Hash)
  end

  it '#create_nic' do
    expect(@nic.type).to eq('nic')
    expect(@nic.id).to match(options[:uuid])
    expect(@nic.properties['name']).to eq('nic1')
    expect(@nic.properties['ips']).to be_kind_of(Array)
    expect(@nic.properties['dhcp']).to be true
    expect(@nic.properties['lan']).to eq(1)
  end

  it '#list_nic' do
    nics = @server.list_nics

    expect(nics.count).to be > 0
    expect(nics[0].type).to eq('nic')
    expect(nics[0].id).to match(options[:uuid])
    expect(nics[0].properties['name']).to eq('nic1')
    expect(nics[0].properties['ips']).to be_kind_of(Array)
    expect(nics[0].properties['dhcp']).to be true
    expect(nics[0].properties['lan']).to eq(1)
  end

  it '#get_nic' do
    nic = @server.get_nic(@nic.id)

    expect(nic.type).to eq('nic')
    expect(nic.id).to match(options[:uuid])
    expect(nic.properties['name']).to eq('nic1')
    expect(nic.properties['ips']).to be_kind_of(Array)
    expect(nic.properties['dhcp']).to be true
    expect(nic.properties['lan']).to eq(1)
  end
end
