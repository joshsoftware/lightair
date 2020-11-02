require 'rails_helper'
module Light
  RSpec.describe Newsletter, type: :model do
    before(:each) do
      @newsletter = FactoryGirl.create(:newsletter)
    end

    describe 'validates' do
      it 'presence of content' do
        expect(@newsletter.content).to be_present 
      end

      it 'presence of sent date' do
        expect(@newsletter.sent_on).to be_present
      end

      it 'presence of user count' do
        expect(@newsletter.users_count).to be_present
      end

      it 'default value of type to be Monthly Newsletter' do
        @newsletter.update_attribute(:newsletter_type, 'Monthly Newsletter')
        expect(@newsletter.newsletter_type).to include('Monthly Newsletter')
      end
    end

    context 'get_image' do
      it 'should return default url if no photo present' do
        expect(@newsletter.get_image).to include('/images/newsletter.jpg')
      end
    end

    context 'opt_in?' do
      it 'should return true if type of newsletter is opt-in' do
        @newsletter.update_attribute(:newsletter_type, 'Opt-In Letter')
        expect(@newsletter.opt_in?).to eq(true)
      end

      it 'should return false if type of newsletter is not opt-in' do
        @newsletter.update_attribute(:newsletter_type, 'Monthly Newsletter')
        expect(@newsletter.opt_in?).to eq(false)
      end
    end

    context 'opt_out?' do
      it 'should return false if type of newsletter is not opt-out' do
        @newsletter.update_attribute(:newsletter_type, 'Monthly Newsletter')
        expect(@newsletter.opt_out?).to eq(false)
      end
    end
  end
end
