require 'rails_helper'
module Light
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
      expect(@newsletter.users_count).to be_present
    end
  end
end
