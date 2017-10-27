require 'spec_helper'

describe ProfitBricks::UserManagement do
  before(:all) do

    @datacenter = ProfitBricks::Datacenter.create(options[:datacenter])
    @datacenter.wait_for { ready? }

    @group = ProfitBricks::UserManagement.create_group(options[:group])
    @group.wait_for { ready? }

    @share = ProfitBricks::Share.create(@group.id, @datacenter.id, options[:share])
    @share.wait_for { ready? }

    @email = "no-reply#{Time.now.to_i}@example.com"
    user = options[:user]
    user[:email] = @email
    @user = ProfitBricks::UserManagement.create_user(user)
    @user.wait_for { ready? }
  end

  after(:all) do
    ProfitBricks::Share.delete(@group.id,@datacenter.id)
    @group.delete()
    @user.delete()
    @datacenter.delete()
  end

  it '#create group failure' do
   expect { ProfitBricks::UserManagement.create_group(options[:bad_group]) }.to raise_error(Excon::Error::UnprocessableEntity)
  end

  it '#create group' do
    expect(@group.id).to match(options[:uuid])
    expect(@group.type).to eq('group')
    expect(@group.properties['name']).to eq('Ruby SDK Test')
    expect(@group.properties['createDataCenter']).to be true
    expect(@group.properties['createSnapshot']).to be true
    expect(@group.properties['reserveIp']).to be true
    expect(@group.properties['accessActivityLog']).to be true
  end

  it '#list group' do
    groups = ProfitBricks::UserManagement.list_group()

    expect(groups.count).to be > 0
  end

  it '#get group' do
    group = ProfitBricks::UserManagement.get_group(@group.id)
    expect(group.type).to eq('group')
    expect(group.properties['name']).to eq('Ruby SDK Test')
    expect(group.properties['createDataCenter']).to be true
    expect(group.properties['createSnapshot']).to be true
    expect(group.properties['reserveIp']).to be true
    expect(group.properties['accessActivityLog']).to be true
  end

  it '#create share' do
    expect(@share.id).to match(options[:uuid])
    expect(@share.type).to eq('resource')
    expect(@share.properties['editPrivilege']).to be true
    expect(@share.properties['sharePrivilege']).to be true
  end

  it '#list share' do
    shares = ProfitBricks::UserManagement.list_share(@group.id)

    expect(shares.count).to be > 0
    expect(shares[0].type).to eq('resource')
  end

  it '#get share' do
    share = ProfitBricks::UserManagement.get_share(@group.id,@share.id)
    expect(share.id).to match(options[:uuid])
    expect(share.type).to eq('resource')
    expect(share.properties['editPrivilege']).to be true
    expect(share.properties['sharePrivilege']).to be true
  end

  it '#create user' do
    expect(@user.id).to match(options[:uuid])
    expect(@user.type).to eq('user')
    expect(@user.properties['firstname']).to eq('John')
    expect(@user.properties['lastname']).to eq('Doe')
    expect(@user.properties['email']).to eq(@email)
    #Password is not present in Create user response
    #expect(@user.password).to eq('secretpassword123')
    expect(@user.properties['administrator']).to be true
  end

  it '#list user' do
    users = ProfitBricks::UserManagement.list_user()

    expect(users.count).to be > 0
    expect(users[0].type).to eq('user')
  end

  it '#get user' do
    user = ProfitBricks::UserManagement.get_user(@user.id)
    expect(user.id).to match(options[:uuid])
    expect(user.type).to eq('user')
    expect(user.properties['firstname']).to eq('John')
    expect(user.properties['lastname']).to eq('Doe')
    expect(user.properties['email']).to eq(@email)
    expect(user.properties['administrator']).to be true
    expect(user.properties['forceSecAuth']).to be false
    expect(user.properties['secAuthActive']).to be false
  end

end
