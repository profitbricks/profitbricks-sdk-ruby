require 'spec_helper'

describe ProfitBricks::Firewall do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, options[:server])
    @server.wait_for { ready? }

    @nic = ProfitBricks::NIC.create(@datacenter.id, @server.id, options[:nic])
    @nic.wait_for { ready? }

    @fwrule = ProfitBricks::Firewall.create(@datacenter.id, @server.id, @nic.id, options[:fwrule])
    @fwrule.wait_for { ready? }
  end

  after(:all) do
    @datacenter.delete
  end

  it '#create' do
    expect(@fwrule.type).to eq('firewall-rule')
    expect(@fwrule.id).to match(options[:uuid])
    expect(@fwrule.properties['name']).to eq('SSH')
    expect(@fwrule.properties['protocol']).to eq('TCP')
    expect(@fwrule.properties['sourceMac']).to eq('01:23:45:67:89:00')
    expect(@fwrule.properties['sourceIp']).to be nil
    expect(@fwrule.properties['targetIp']).to be nil
    expect(@fwrule.properties['portRangeStart']).to eq(22)
    expect(@fwrule.properties['portRangeEnd']).to eq(22)
    expect(@fwrule.properties['icmpType']).to be nil
    expect(@fwrule.properties['icmpCode']).to be nil
  end

  it '#list' do
    fwrules = ProfitBricks::Firewall.list(@datacenter.id, @server.id, @nic.id)

    expect(fwrules.count).to be > 0
    expect(fwrules[0].type).to eq('firewall-rule')
    expect(fwrules[0].id).to eq(@fwrule.id)
    expect(fwrules[0].properties['name']).to eq('SSH')
    expect(fwrules[0].properties['protocol']).to eq('TCP')
    expect(fwrules[0].properties['sourceMac']).to eq('01:23:45:67:89:00')
    expect(fwrules[0].properties['sourceIp']).to be nil
    expect(fwrules[0].properties['targetIp']).to be nil
    expect(fwrules[0].properties['portRangeStart']).to eq(22)
    expect(fwrules[0].properties['portRangeEnd']).to eq(22)
    expect(fwrules[0].properties['icmpType']).to be nil
    expect(fwrules[0].properties['icmpCode']).to be nil
  end

  it '#get' do
    fwrule = ProfitBricks::Firewall.get(@datacenter.id, @server.id, @nic.id, @fwrule.id)

    expect(fwrule.type).to eq('firewall-rule')
    expect(fwrule.id).to eq(@fwrule.id)
    expect(fwrule.properties['name']).to eq('SSH')
    expect(fwrule.properties['protocol']).to eq('TCP')
    expect(fwrule.properties['sourceMac']).to eq('01:23:45:67:89:00')
    expect(fwrule.properties['sourceIp']).to be nil
    expect(fwrule.properties['targetIp']).to be nil
    expect(fwrule.properties['portRangeStart']).to eq(22)
    expect(fwrule.properties['portRangeEnd']).to eq(22)
    expect(fwrule.properties['icmpType']).to be nil
    expect(fwrule.properties['icmpCode']).to be nil
  end

  it '#update' do
    fwrule = @fwrule.update(
      sourceMac: '01:98:22:22:44:22',
      targetIp: '123.100.101.102'
    )
    fwrule.wait_for { ready? }

    expect(fwrule.type).to eq('firewall-rule')
    expect(fwrule.id).to eq(@fwrule.id)
    expect(fwrule.properties['name']).to eq('SSH')
    expect(fwrule.properties['protocol']).to eq('TCP')
    expect(fwrule.properties['sourceMac']).to eq('01:98:22:22:44:22')
    expect(fwrule.properties['sourceIp']).to be nil
    expect(fwrule.properties['targetIp']).to eq('123.100.101.102')
    expect(fwrule.properties['portRangeStart']).to eq(22)
    expect(fwrule.properties['portRangeEnd']).to eq(22)
    expect(fwrule.properties['icmpType']).to be nil
    expect(fwrule.properties['icmpCode']).to be nil
  end

  it '#delete' do
    fwrule = ProfitBricks::Firewall.create(@datacenter.id, @server.id, @nic.id, options[:fwrule])
    fwrule.wait_for { ready? }

    expect(fwrule.delete.requestId).to match(options[:uuid])
  end
end
