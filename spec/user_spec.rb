require 'spec_helper'

describe ProfitBricks::User do
  before(:all) do
    @email = "no-reply#{Time.now.to_i}@example.com"
    @email1 = "no-reply#{Time.now.to_i+1}@example.com"
    @group = ProfitBricks::Group.create(options[:group])
    @group.wait_for { ready? }

    user = options[:user]
    user[:email] = @email
    @user = ProfitBricks::User.create(user)
    @user.wait_for { ready? }
  end

  after(:all) do
    @group.delete()
    @user.delete()
  end

  it '#create failure' do
   expect { ProfitBricks::User.create(options[:bad_user]) }.to raise_error(Excon::Error::UnprocessableEntity)
  end

  it '#create' do
    expect(@user.id).to match(options[:uuid])
    expect(@user.type).to eq('user')
    expect(@user.properties['firstname']).to eq('John')
    expect(@user.properties['lastname']).to eq('Doe')
    expect(@user.properties['email']).to eq(@email)
    #Password is not present in Create user response
    #expect(@user.password).to eq('secretpassword123')
    expect(@user.properties['administrator']).to be true
  end

  it '#list' do
    users = ProfitBricks::User.list()

    expect(users.count).to be > 0
    expect(users[0].type).to eq('user')
  end

  it '#get' do
    user = ProfitBricks::User.get(@user.id)
    expect(user.id).to match(options[:uuid])
    expect(user.type).to eq('user')
    expect(user.properties['firstname']).to eq('John')
    expect(user.properties['lastname']).to eq('Doe')
    expect(user.properties['email']).to eq(@email)
    #Password is not present in user response
    #expect(user.properties['password']).to eq('secretpassword123')
    expect(user.properties['administrator']).to be true
    expect(user.properties['forceSecAuth']).to be false
    expect(user.properties['secAuthActive']).to be false
  end

  it '#get failure' do
      expect { ProfitBricks::User.get(options[:bad_id]) }.to raise_error(Excon::Error::NotFound)
  end

  it '#update' do
    user = @user.update(
    firstname: 'Jane',
    lastname: 'Doe',
    administrator: false,
    email: @email
    )

    expect(user.id).to match(options[:uuid])
    expect(user.type).to eq('user')
    expect(user.properties['firstname']).to eq('Jane')
    expect(user.properties['lastname']).to eq('Doe')
    expect(user.properties['email']).to eq(@email)
    expect(user.properties['administrator']).to be false
    expect(user.properties['secAuthActive']).to be false
  end

  it '#delete' do
    user = options[:user]
    user[:email] = @email1
    user = ProfitBricks::User.create(user)
    user.wait_for { ready? }

    expect(user.delete.requestId).to match(options[:uuid])
  end

  it '#add user to group' do
    user = ProfitBricks::User.add_to_group(@group.id,@user.id)
    expect(user.id).to match(options[:uuid])
    expect(user.type).to eq('user')
  end

  it '#remove user from group' do
    expect(ProfitBricks::User.remove_from_group(@group.id,@user.id)).to be true
  end
end
