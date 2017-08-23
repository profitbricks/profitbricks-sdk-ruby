require 'spec_helper'

describe ProfitBricks::Image do
  before(:all) do
    @images = ProfitBricks::Image.list
  end

  it '#list' do
    expect(@images.count).to be > 0
    expect(@images[0].type).to eq('image')
    expect(@images[0].id).to match(options[:uuid])
    expect(@images[0].properties['name']).to be_kind_of(String)
    expect(@images[0].properties['description']).to eq('')
    expect(@images[0].properties['location']).to match(/\w+\/\w+/)
    expect(@images[0].properties['size']).to be > 0
  end

  it '#get' do
    image = ProfitBricks::Image.get(@images[0].id)

    expect(image.type).to eq('image')
    expect(image.id).to match(options[:uuid])
    expect(image.properties['name']).to be_kind_of(String)
    expect(image.properties['name']).not_to be nil
    expect(image.properties['description']).to be nil
    expect(image.properties['location']).to match(/\w+\/\w+/)
    expect(image.properties['size']).to be > 0

    expect(image.properties['cpuHotPlug']).to eq(true).or(eq(false))
    expect(image.properties['cpuHotUnplug']).to eq(true).or(eq(false))
    expect(image.properties['ramHotPlug']).to eq(true).or(eq(false))
    expect(image.properties['ramHotUnplug']).to eq(true).or(eq(false))
    expect(image.properties['nicHotPlug']).to eq(true).or(eq(false))
    expect(image.properties['nicHotUnplug']).to eq(true).or(eq(false))
    expect(image.properties['discVirtioHotPlug']).to eq(true).or(eq(false))
    expect(image.properties['discVirtioHotUnplug']).to eq(true).or(eq(false))
    expect(image.properties['discScsiHotPlug']).to eq(true).or(eq(false))
    expect(image.properties['discScsiHotUnplug']).to eq(true).or(eq(false))
    expect(image.properties['public']).to eq(true).or(eq(false))

    expect(image.properties['imageAliases']).to be_an_instance_of(Array)

    expect(image.properties).to have_key("location")
    expect(image.properties).to have_key("licenceType")
    expect(image.properties).to have_key("imageType")
  end

  it '#get failure' do
      expect { ProfitBricks::Image.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound, /Resource does not exist/)
  end

  # Unable to test in production due to public images.
  #
  # it '#update' do
  #   image = @images[0]
  #   image = image.update(name: 'New name')
  #
  #   expect(image.type).to eq('image')
  #   expect(image.id).to be_kind_of(String)
  #   expect(image.properties['name']).to eq('New name')
  #   expect(image.properties['description']).to be nil
  #   expect(image.properties['location']).to match(/\w+\/\w+/)
  #   expect(image.properties['size']).to be_kind_of(Integer)
  # end

  # Unable to test in production at the moment. Images must be uploaded
  # via FTP in production before a delete can be performed.
  #
  # it '#delete' do
  #   skip 'Not sure how to test against production API.'
  # end
end
