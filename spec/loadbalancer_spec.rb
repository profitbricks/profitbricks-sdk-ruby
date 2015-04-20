require 'spec_helper'

describe ProfitBricks::Loadbalancer do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @lan = ProfitBricks::LAN.create(@datacenter.id, options[:lan])
    @lan.wait_for { ready? }

    @nic = ProfitBricks::NIC.create(@datacenter.id, @server.id, options[:nic])
    @nic.wait_for { ready? }

    @loadbalancer = ProfitBricks::Loadbalancer.create(@datacenter.id, options[:loadbalancer])
    @loadbalancer.wait_for { ready? }

    @balanced_nic = @loadbalancer.associate_balanced_nic(@nic.id)
    @balanced_nic.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@loadbalancer.type).to eq('loadbalancer')
    expect(@loadbalancer.id).to be_kind_of(String)
    expect(@loadbalancer.properties['name']).to eq('My LB')
    expect(@loadbalancer.properties['ip']).to be nil
    expect(@loadbalancer.properties['dhcp']).to be true
    expect(@loadbalancer.entities).to be nil
  end

  it '#list' do
    loadbalancers = ProfitBricks::Loadbalancer.list(@datacenter.id)

    expect(loadbalancers.count).to be > 0
    expect(loadbalancers[0].type).to eq('loadbalancer')
    expect(loadbalancers[0].id).to eq(@loadbalancer.id)
    expect(loadbalancers[0].properties['name']).to eq('My LB')
    expect(loadbalancers[0].properties['ip']).to be_kind_of(String)
    expect(loadbalancers[0].properties['dhcp']).to be true
    expect(loadbalancers[0].entities).to be_kind_of(Hash)
  end

  it '#get' do
    loadbalancer = ProfitBricks::Loadbalancer.get(@datacenter.id, @loadbalancer.id)

    expect(loadbalancer.type).to eq('loadbalancer')
    expect(loadbalancer.id).to eq(@loadbalancer.id)
    expect(loadbalancer.properties['name']).to eq('My LB')
    expect(loadbalancer.properties['ip']).to be_kind_of(String)
    expect(loadbalancer.properties['dhcp']).to be true
    expect(loadbalancer.entities).to be_kind_of(Hash)
  end

  it '#update' do
    loadbalancer = @loadbalancer.update(
      ip: '10.1.1.2'
    )
    loadbalancer.wait_for { ready? }

    expect(loadbalancer.type).to eq('loadbalancer')
    expect(loadbalancer.id).to eq(@loadbalancer.id)
    expect(loadbalancer.properties['name']).to eq('My LB')
    expect(loadbalancer.properties['ip']).to eq('10.1.1.2')
    expect(loadbalancer.properties['dhcp']).to be true
    expect(loadbalancer.entities).to be nil
  end

  it '#delete' do
    loadbalancer = ProfitBricks::Loadbalancer.create(@datacenter.id, options[:loadbalancer])
    loadbalancer.wait_for { ready? }

    expect(loadbalancer.delete).to have_key(:requestId)
  end

  it '#list_balanced_nics' do
    balanced_nics = @loadbalancer.list_balanced_nics

    expect(balanced_nics.count).to be > 0
    expect(balanced_nics[0].type).to eq('nic')
    expect(balanced_nics[0].properties['name']).to eq('nic1')
    expect(balanced_nics[0].properties['ips']).to be_kind_of(Array)
    expect(balanced_nics[0].properties['dhcp']).to be true
    expect(balanced_nics[0].properties['lan']).to be_kind_of(Integer)
  end

  it '#get_balanced_nic' do
    balanced_nic = @loadbalancer.get_balanced_nic(@nic.id)

    expect(balanced_nic.type).to eq('nic')
    expect(balanced_nic.properties['name']).to eq('nic1')
    expect(balanced_nic.properties['ips']).to be_kind_of(Array)
    expect(balanced_nic.properties['dhcp']).to be true
    expect(balanced_nic.properties['lan']).to be_kind_of(Integer)
  end

  it '#associate_balanced_nic' do
    balanced_nic = @loadbalancer.associate_balanced_nic(@nic.id)

    expect(balanced_nic.type).to eq('nic')
    expect(balanced_nic.properties['name']).to eq('nic1')
    expect(balanced_nic.properties['ips']).to be_kind_of(Array)
    expect(balanced_nic.properties['dhcp']).to be true
    expect(balanced_nic.properties['lan']).to be_kind_of(Integer)
  end

  it '#remove_balanced_nic' do
    @loadbalancer.associate_balanced_nic(@nic.id)

    expect(@loadbalancer.remove_balanced_nic(@nic.id)).to have_key(:requestId)
  end
end
