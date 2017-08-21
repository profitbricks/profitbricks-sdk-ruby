require 'spec_helper'

describe ProfitBricks::Resource do
  before(:all) do
    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    # images = ProfitBricks::Image.list
    # @image = images[0]

    @volume = ProfitBricks::Volume.create(@datacenter.id, options[:volume])
    @volume.wait_for { ready? }

    @snapshot = ProfitBricks::Snapshot.create(@datacenter.id, @volume.id, options[:snapshot])
    @snapshot.wait_for { ready? }

    @ipblock = ProfitBricks::IPBlock.reserve(options[:ipblock])
    @ipblock.wait_for { ready? }
  end

  after(:all) do
    @snapshot.delete
    @volume.delete
    @ipblock.release
    @datacenter.delete
  end

  it '#list' do
    resources = ProfitBricks::Resource.list

    expect(resources.count).to be > 0
    #expect(resources.type).to eq('collection')
  end

  it '#list datacenter' do
    resources = ProfitBricks::Resource.list_by_type('datacenter')

    expect(resources.count).to be > 0
    expect(resources[0].type).to eq('datacenter')
  end

  # Unable to test in production at the moment. Images must be uploaded
  # via FTP in production before a delete can be performed.
  # it '#list image' do
  #   resources = ProfitBricks::Resource.list_by_type('image')
  #
  #   expect(resources.count).to be > 0
  #   expect(resources[0].type).to eq('image')
  # end

  it '#list snapshot' do
    resources = ProfitBricks::Resource.list_by_type('snapshot')

    expect(resources.count).to be > 0
    expect(resources[0].type).to eq('snapshot')
  end

  it '#list ipblock' do
    resources = ProfitBricks::Resource.list_by_type('ipblock')

    expect(resources.count).to be > 0
    expect(resources[0].type).to eq('ipblock')
  end

  it '#list failure' do
    expect { ProfitBricks::Resource.list_by_type('unknown') }.to raise_error(Excon::Error::NotFound)
  end

  it '#get datacenter' do
    resource = ProfitBricks::Resource.get('datacenter', @datacenter.id)

    expect(resource.id).to match(options[:uuid])
    expect(resource.type).to eq('datacenter')
  end

  # Unable to test in production at the moment. Images must be uploaded
  # via FTP in production before a delete can be performed.
  # it '#get image' do
  #   resource = ProfitBricks::Resource.get('image', @image.id)
  #
  #   expect(resource.id).to match(options[:uuid])
  #   expect(resource.type).to eq('image')
  # end

  it '#get snapshot' do
    resource = ProfitBricks::Resource.get('snapshot', @snapshot.id)

    expect(resource.id).to match(options[:uuid])
    expect(resource.type).to eq('snapshot')
  end

  it '#get ipblock' do
    resource = ProfitBricks::Resource.get('ipblock', @ipblock.id)

    expect(resource.id).to match(options[:uuid])
    expect(resource.type).to eq('ipblock')
  end

  it '#get failure' do
    expect { ProfitBricks::Resource.get('unknown', options[:bad_id]) }.to raise_error(Excon::Error::NotFound)
  end
end
