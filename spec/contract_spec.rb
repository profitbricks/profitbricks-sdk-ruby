require 'spec_helper'

describe ProfitBricks::Contract do
  before(:all) do
    @contract = ProfitBricks::Contract.get
  end

  it '#get' do
    expect(@contract.type).to eq('contract')
    expect(@contract.properties['contractNumber']).to be_kind_of(Integer)
    expect(@contract.properties['owner']).to be_kind_of(String)
    expect(@contract.properties['status']).to be_kind_of(String)
  end

  it '#get_by_contract_id' do
    contract = ProfitBricks::Contract.get_by_contract_id(@contract.properties['contractNumber'])

    expect(contract.type).to eq('contract')
    expect(contract.properties['contractNumber']).to be_kind_of(Integer)
    expect(contract.properties['contractNumber']).to eq(@contract.properties['contractNumber'])
    expect(contract.properties['owner']).to be_kind_of(String)
    expect(contract.properties['status']).to be_kind_of(String)
  end
end
