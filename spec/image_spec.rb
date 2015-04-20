require 'spec_helper'

describe ProfitBricks::Image do
  before(:all) do
    @images = ProfitBricks::Image.list
  end

  it '#list' do
    expect(@images.count).to be > 0
    expect(@images[0].type).to eq('image')
    expect(@images[0].id).to be_kind_of(String)
    expect(@images[0].properties['name']).to be_kind_of(String)
    expect(@images[0].properties['description']).to be nil
    expect(@images[0].properties['location']).to match(/\w+\/\w+/)
    expect(@images[0].properties['size']).to be_kind_of(Integer)
  end

  it '#get' do
    image = ProfitBricks::Image.get(@images[0].id)

    expect(image.type).to eq('image')
    expect(image.id).to be_kind_of(String)
    expect(image.properties['name']).to be_kind_of(String)
    expect(image.properties['description']).to be nil
    expect(image.properties['location']).to match(/\w+\/\w+/)
    expect(image.properties['size']).to be_kind_of(Integer)
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
