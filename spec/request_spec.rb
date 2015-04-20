require 'spec_helper'

describe ProfitBricks::Request do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @request = ProfitBricks::Request.get(@datacenter.requestId)
  end

  after(:all) do
    @datacenter.delete
  end

  it '#list' do
    requests = ProfitBricks::Request.list

    expect(requests.count).to be > 0
    expect(requests[0].type).to eq('request')
    expect(requests[0].id).to be_kind_of(String)
  end

  it '#get' do
    request = ProfitBricks::Request.get(@request.id)

    expect(request.type).to eq('request')
    expect(request.id).to be_kind_of(String)
    expect(request.properties['method']).to eq('POST')
  end

  it '#status' do
    status = @request.status

    expect(status.type).to eq('request-status')
    expect(status.metadata['status']).to eq('DONE')
  end
end
