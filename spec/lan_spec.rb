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
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@lan.type).to eq('lan')
    expect(@lan.id).to match(/^\d+$/)
    expect(@lan.properties['name']).to eq('public Lan 4')
    expect(@lan.properties['public']).to be true
  end

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
    expect(lans[0].properties['name']).to eq('public Lan 4')
    expect(lans[0].properties['public']).to be true
  end

  it '#get' do
    lan = ProfitBricks::LAN.get(@datacenter.id, @lan.id)

    expect(lan.type).to eq('lan')
    expect(lan.id).to eq(@lan.id)
    expect(lan.properties['name']).to eq('public Lan 4')
    expect(lan.properties['public']).to be true
  end

  it '#update' do
    lan = @lan.update(public: false)

    expect(lan.type).to eq('lan')
    expect(lan.id).to eq(@lan.id)
    expect(lan.properties['name']).to eq('public Lan 4')
    expect(lan.properties['public']).to be false
  end

  it '#delete' do
    lan = ProfitBricks::LAN.create(@datacenter.id, options[:lan])
    lan.wait_for { ready? }

    expect(lan.delete.requestId).to match(options[:uuid])
  end
end
