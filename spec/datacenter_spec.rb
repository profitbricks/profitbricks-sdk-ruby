require 'spec_helper'

describe ProfitBricks::Datacenter do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @composite_datacenter= ProfitBricks::Datacenter.create(options[:datacenter_composite])
    @datacenter.wait_for { ready? }

    @server = @datacenter.create_server(options[:server])
    @server.wait_for { ready? }

    @volume = @datacenter.create_volume(options[:volume])
    @volume.wait_for { ready? }

    @loadbalancer = @datacenter.create_loadbalancer(options[:loadbalancer])
    @loadbalancer.wait_for { ready? }

    @lan = @datacenter.create_lan(options[:lan])
    @lan.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
    @composite_datacenter.delete
  end

  it '#create simple' do
    expect(@datacenter.type).to eq('datacenter')
    expect(@datacenter.id).to match(options[:uuid])
    expect(@datacenter.properties['name']).to eq('Ruby SDK Test')
    expect(@datacenter.properties['description']).to eq('Ruby SDK test datacenter')
    expect(@datacenter.properties['location']).to eq('us/las')
  end

  it '#create failure' do
   expect { ProfitBricks::Datacenter.create(options[:bad_datacenter]) }.to raise_error(Excon::Error::UnprocessableEntity, /Attribute 'location' is required/)
  end

  it '#create composite' do
    @composite_datacenter.wait_for(300) { ready? }
    @composite_datacenter.reload

    expect(@composite_datacenter.type).to eq('datacenter')
    expect(@composite_datacenter.id).to match(options[:uuid])
    expect(@composite_datacenter.properties['name']).to eq('Ruby SDK Test Composite')
    expect(@composite_datacenter.properties['description']).to eq('Ruby SDK test composite datacenter')
    expect(@composite_datacenter.properties['location']).to eq('us/las')
    expect(@composite_datacenter.entities['servers']['items'].count).to be > 0
    expect(@composite_datacenter.entities['volumes']['items'].count).to be > 0
  end

  it '#list' do
    datacenters = ProfitBricks::Datacenter.list

    expect(datacenters.count).to be > 0
    expect(datacenters[0].type).to eq('datacenter')
    expect(datacenters[0].id).to match(options[:uuid])
  end

  it '#get' do
    datacenter = ProfitBricks::Datacenter.get(@datacenter.id)

    expect(datacenter.type).to eq('datacenter')
    expect(datacenter.id).to eq(@datacenter.id)
    expect(datacenter.properties['name']).to eq('Ruby SDK Test')
    expect(datacenter.properties['description']).to eq('Ruby SDK test datacenter')
    expect(datacenter.properties['location']).to eq('us/las')
    expect(datacenter.properties['version']).to be_kind_of(Integer)
  end

  it '#get failure' do
    expect { ProfitBricks::Datacenter.get("bad_id") }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  it '#update' do
    datacenter = ProfitBricks::Datacenter.get(@datacenter.id)
    datacenter.update(name: 'Ruby SDK Test - RENAME')

    expect(datacenter.id).to eq(@datacenter.id)
    expect(datacenter.properties['name']).to eq('Ruby SDK Test - RENAME')
    expect(datacenter.properties['location']).to eq('us/las')
    expect(datacenter.properties['version']).to be_kind_of(Integer)
    expect(datacenter.properties['version']).to be > 0
  end

  it '#delete' do
    datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    datacenter.wait_for { ready? }

    expect(datacenter.delete.requestId).to match(options[:uuid])
    expect(datacenter.wait_for { ready? }).to be_kind_of(Hash)
  end

  it '#list_servers' do
    servers = @datacenter.list_servers

    expect(servers[0].type).to eq('server')
    expect(servers[0].id).to match(options[:uuid])
    expect(servers[0].properties['name']).to eq('Ruby SDK Test')
    expect(servers[0].properties['cores']).to be_kind_of(Integer)
    expect(servers[0].properties['ram']).to eq(1024)
    expect(servers[0].properties['availabilityZone']).to eq('ZONE_1')
    expect(servers[0].properties['vmState']).to eq('RUNNING')
    expect(servers[0].properties['bootVolume']).to be nil
    expect(servers[0].properties['bootCdrom']).to be nil
  end

  it '#get_server' do
    server = @datacenter.get_server(@server.id)

    expect(server.type).to eq('server')
    expect(server.id).to match(options[:uuid])
    expect(server.properties['name']).to eq('Ruby SDK Test')
    expect(server.properties['cores']).to be_kind_of(Integer)
    expect(server.properties['ram']).to eq(1024)
    expect(server.properties['availabilityZone']).to eq('ZONE_1')
    expect(server.properties['vmState']).to eq('RUNNING')
    expect(server.properties['bootVolume']).to be nil
    expect(server.properties['bootCdrom']).to be nil
  end

  it '#create_server' do
    server = @datacenter.get_server(@server.id)

    expect(server.type).to eq('server')
    expect(server.id).to eq(@server.id)
    expect(server.properties['name']).to eq('Ruby SDK Test')
    expect(server.properties['cores']).to be_kind_of(Integer)
    expect(server.properties['ram']).to eq(1024)
    expect(server.properties['availabilityZone']).to eq('ZONE_1')
    expect(server.properties['vmState']).to eq('RUNNING')
    expect(server.properties['bootVolume']).to be nil
    expect(server.properties['bootCdrom']).to be nil
  end

  it '#list_volumes' do
    volumes = @datacenter.list_volumes

    expect(volumes[0].type).to eq('volume')
    expect(volumes[0].id).to match(options[:uuid])
    expect(volumes[0].properties['name']).to eq('Ruby SDK Test')
    expect(volumes[0].properties['size']).to eq(2)
    expect(volumes[0].properties['bus']).to be nil
    expect(volumes[0].properties['image']).to be nil
    expect(volumes[0].properties['imagePassword']).to be nil
    expect(volumes[0].properties['type']).to eq('HDD')
    expect(volumes[0].properties['discVirtioHotPlug']).to be false
    expect(volumes[0].properties['discVirtioHotUnplug']).to be false
  end

  it '#get_volume' do
    volume = @datacenter.get_volume(@volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.id).to match(options[:uuid])
    expect(volume.properties['name']).to eq('Ruby SDK Test')
    expect(volume.properties['size']).to eq(2)
    expect(volume.properties['bus']).to be nil
    expect(volume.properties['image']).to be nil
    expect(volume.properties['imagePassword']).to be nil
    expect(volume.properties['type']).to eq('HDD')
    expect(volume.properties['discVirtioHotPlug']).to be false
    expect(volume.properties['discVirtioHotUnplug']).to be false
  end

  it '#create_volume' do
    # Tests should pass as volume as already been created.
    volume = @datacenter.get_volume(@volume.id)

    expect(volume.type).to eq('volume')
    expect(volume.id).to match(options[:uuid])
    expect(volume.properties['name']).to eq('Ruby SDK Test')
    expect(volume.properties['size']).to eq(2)
    expect(volume.properties['bus']).to be nil
    expect(volume.properties['image']).to be nil
    expect(volume.properties['imagePassword']).to be nil
    expect(volume.properties['type']).to eq('HDD')
    expect(volume.properties['discVirtioHotPlug']).to be false
    expect(volume.properties['discVirtioHotUnplug']).to be false
  end

  it '#list_loadbalancers' do
    loadbalancers = @datacenter.list_loadbalancers

    expect(loadbalancers[0].type).to eq('loadbalancer')
    expect(loadbalancers[0].id).to be_kind_of(String)
    expect(loadbalancers[0].properties['name']).to eq('Ruby SDK Test')
    expect(loadbalancers[0].properties['ip']).to be nil
    expect(loadbalancers[0].properties['dhcp']).to be true
  end

  it '#get_loadbalancer' do
    loadbalancer = @datacenter.get_loadbalancer(@loadbalancer.id)

    expect(loadbalancer.type).to eq('loadbalancer')
    expect(loadbalancer.id).to be_kind_of(String)
    expect(loadbalancer.properties['name']).to eq('Ruby SDK Test')
    expect(loadbalancer.properties['ip']).to be nil
    expect(loadbalancer.properties['dhcp']).to be true
  end

  it '#create_loadbalancer' do
    # Tests should pass as the loadbalancer has already been created.
    loadbalancer = @datacenter.get_loadbalancer(@loadbalancer.id)

    expect(loadbalancer.type).to eq('loadbalancer')
    expect(loadbalancer.id).to be_kind_of(String)
    expect(loadbalancer.properties['name']).to eq('Ruby SDK Test')
    expect(loadbalancer.properties['ip']).to be nil
    expect(loadbalancer.properties['dhcp']).to be true
  end

  it '#list_lans' do
    lans = @datacenter.list_lans

    expect(lans[0].type).to eq('lan')
    expect(lans[0].id).to match(/^\d+$/)
    expect(lans[0].properties['name']).to eq('Ruby SDK Test')
    expect(lans[0].properties['public']).to be true
  end

  it '#get_lan' do
    lan = @datacenter.get_lan(@lan.id)

    expect(lan.type).to eq('lan')
    expect(lan.id).to match(/^\d+$/)
    expect(lan.properties['name']).to eq('Ruby SDK Test')
    expect(lan.properties['public']).to be true
  end

  it '#create_lan' do
    lan = @datacenter.get_lan(@lan.id)

    expect(lan.type).to eq('lan')
    expect(lan.id).to match(/^\d+$/)
    expect(lan.properties['name']).to eq('Ruby SDK Test')
    expect(lan.properties['public']).to be true
  end
end
