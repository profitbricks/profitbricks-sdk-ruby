require 'spec_helper'

describe ProfitBricks::LAN do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @lan = ProfitBricks::LAN.create(@datacenter.id, options[:lan])
    @lan.wait_for { ready? }

    @nic = ProfitBricks::NIC.create(@datacenter.id, @server.id, lan: @lan.id)
    @nic.wait_for { ready? }

    @ip_block = ProfitBricks::IPBlock.reserve(options[:ipblock_failover])
    @ip_block.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
    @datacenter.wait_for { ready? }
    @ip_block.release
    @ip_block.wait_for { ready? }
  end

  it '#create' do
    expect(@lan.type).to eq('lan')
    expect(@lan.id).to match(/^\d+$/)
    expect(@lan.properties['name']).to eq('Ruby SDK Test')
    expect(@lan.properties['public']).to be true
  end

  # it '#create failure' do
  #  expect { ProfitBricks::LAN.create(options[:bad_id], options[:bad_lan]) }.to raise_error(Excon::Error::UnprocessableEntity, /Attribute 'location' is required/)
  # end

  it '#create composite' do
    create_data=options[:lan]
    nics=[@nic.id]
    create_data['nics']=nics
    @lan_composite = ProfitBricks::LAN.create(@datacenter.id,create_data)
    @lan_composite.wait_for { ready? }
    expect(@lan_composite.type).to eq('lan')
    expect(@lan_composite.entities['nics']['items'].size).to eq(1)
  end

  it '#list' do
    lans = ProfitBricks::LAN.list(@datacenter.id)

    expect(lans.count).to be > 0
    expect(lans[0].type).to eq('lan')
    expect(lans[0].id).to match(/^\d+$/)
    expect(lans[0].properties['name']).to eq('Ruby SDK Test')
    expect(lans[0].properties['public']).to be true
  end

  it '#get' do
    lan = ProfitBricks::LAN.get(@datacenter.id, @lan.id)

    expect(lan.type).to eq('lan')
    expect(lan.id).to eq(@lan.id)
    expect(lan.properties['name']).to eq('Ruby SDK Test')
    expect(lan.properties['public']).to be true
  end

  it '#get failure' do
    expect { ProfitBricks::LAN.get(@datacenter.id,options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  it '#update' do
    lan = @lan.update({ public: false, name: 'Ruby SDK Test - RENAME' })

    expect(lan.type).to eq('lan')
    expect(lan.id).to eq(@lan.id)
    expect(lan.properties['name']).to eq('Ruby SDK Test - RENAME')
    expect(lan.properties['public']).to be false
  end

  it '#update_ip_failover' do
    ip = @ip_block.properties['ips'][0]

    server1 = ProfitBricks::Server.create(@datacenter.id, options[:server])
    server1.wait_for { ready? }

    lan = ProfitBricks::LAN.create(@datacenter.id, options[:lan])
    lan.wait_for { ready? }

    nic = ProfitBricks::NIC.create(@datacenter.id, server1.id, { lan: lan.id, ips: [ip] })
    nic.wait_for { ready? }

    ip_failover = {}
    ip_failover['ip'] = ip
    ip_failover['nicUuid'] = nic.id

    lan.update({ipFailover: [ip_failover]})
    lan.wait_for { ready? }

    server2 = ProfitBricks::Server.create(@datacenter.id, options[:server])
    server2.wait_for { ready? }

    nic2 = ProfitBricks::NIC.create(@datacenter.id, server2.id, { lan: lan.id, ips: [ip] })
    nic2.wait_for { ready? }
  end

  it '#delete' do
    lan = ProfitBricks::LAN.create(@datacenter.id, options[:lan])
    lan.wait_for { ready? }

    expect(lan.delete.requestId).to match(options[:uuid])
  end
end
