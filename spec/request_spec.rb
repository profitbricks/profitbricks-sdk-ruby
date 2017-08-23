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
    expect(requests[0].id).to match(options[:uuid])
  end

  it '#get' do
    request = ProfitBricks::Request.get(@request.id)

    expect(request.type).to eq('request')
    expect(request.id).to match(options[:uuid])
    expect(request.properties['method']).to eq('POST')
  end

  it '#get failure' do
     expect { ProfitBricks::Request.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  it '#status' do
    status = @request.status

    expect(status.type).to eq('request-status')
    expect(status.id).to eq("#{@request.id}/status")
    expect(status.metadata['status']).to eq('DONE')
  end
end
