require 'rails_helper'

RSpec.describe Newsletter, :type => :model do
  before(:each) do
    @newsletter = FactoryGirl.create(:newsletter)
  end

  it "validates presence of content" do
    expect(@newsletter.content).to be_present 
  end

  it "validates presence of sent date" do
    expect(@newsletter.sent_on).to be_present
  end

  it "validates presence of user count" do
    expect(@newsletter.user_count).to be_present
  end

  it "validates updation of user count" do
    a = Newsletter.new(@newsletter.attributes)
    expect(a).not_to be_valid 
  end
end
