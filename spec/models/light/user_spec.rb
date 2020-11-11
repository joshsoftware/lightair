require 'rails_helper'
module Light
RSpec.describe User, type: :model do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  it 'validates presence of email_id' do
    expect(@user.email_id).to be_present
  end

  it 'validates presence of subcription' do
    expect(@user.is_subscribed).to be_present
  end

  it 'validates presence of joined date' do
    expect(@user.joined_on).to be_present
  end

  it 'validates presence of source' do
    expect(@user.source).to be_present
  end

  it 'validates uniqueness of email id' do
    k=User.new(@user.attributes)
    expect(k).not_to be_valid
  end

  let(:user) {FactoryGirl.create(:user)}
  let(:newsletter) {FactoryGirl.create(:newsletter)}
end
end
