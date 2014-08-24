require "rails_helper"
module Light

RSpec.describe UserMailer, :type => :mailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    UserMailer.welcome_message('kanhaiya@joshsoftware.com', FactoryGirl.create(:newsletter), '123', 'kanhaiya').deliver
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end


  it 'should send an email' do
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  it 'renders the receiver email' do
    expect(ActionMailer::Base.deliveries.first.to).to eq(['kanhaiya@joshsoftware.com'])
  end

  it 'render the sender email' do
    expect(ActionMailer::Base.deliveries.first.from).to eq(['marketing@joshsoftware.com'])
    end

end
end
