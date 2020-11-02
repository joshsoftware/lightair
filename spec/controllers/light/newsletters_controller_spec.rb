require 'rails_helper'

module Light

  RSpec.describe NewslettersController, type: :controller do

    routes { Light::Engine.routes}

    context 'GET index' do
      it 'list all the newsletters' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'list all the newsletters' do
        get :index, {type: 'Opt-In Letter'}
        expect(response).to have_http_status(:success)
      end
    end

    context 'GET show' do
      let(:newsletter) {FactoryGirl.create(:newsletter)}

      it 'show the details of the newsletters' do
        get :show, {id: newsletter.id}
        expect(assigns(:newsletter)).to eq(newsletter)
        expect(response).to render_template('show')
      end
    end

    context 'GET new' do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}

      it 'display new form for adding newsletter' do
        get :new, {newsletter: new_newsletter}
        expect(assigns(:newsletter).new_record?).to eq(true)
        expect(response).to render_template('new')
      end
    end

    context 'POST create' do
      let(:new_newsletter) {FactoryGirl.attributes_for(:newsletter)}

      it 'display new form for adding newsletter' do
        post :create, {newsletter: new_newsletter}

        expect(Newsletter.count).to eq(1)
        expect(flash[:success]).to eq('Newsletter created successfully')
        expect(response).to redirect_to(newsletters_path(type: 'Monthly Newsletter'))
      end

      it 'create a newsletter failure' do
        post :create, {newsletter: {content: '', sent_on: '2014-1-1', users_count: 0}}
        expect(flash[:error]).to eq('Error while creating newsletter')
        expect(response).to render_template('new')
      end
    end

    context 'GET edit' do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}

      it 'fetches the specific newsletter' do
        get :edit, {id: new_newsletter.id}
        expect(assigns(:newsletter)).to eq(new_newsletter)
        expect(response).to render_template('edit')
      end
    end

    context 'PUT update' do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}

      it 'updates details of specified newsletter' do
        put :update, {id: new_newsletter.id, newsletter: {subject: 'August 2020'}}
 
        expect(flash[:success]).to eq('Newsletter updated successfully')
        expect(new_newsletter.reload.subject).to eq('August 2020')
        expect(response).to redirect_to(newsletters_path(type: new_newsletter.newsletter_type))
      end

      it 'update a newsletter failure' do
        put :update, {id: new_newsletter.id, newsletter: {content: ''}}

        expect(flash[:error]).to eq('Error while updating newsletter')
        expect(response).to render_template('edit')
      end
    end

    context 'DELETE delete' do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      
      it 'delete a newsletter success' do
        delete :destroy, {id: newsletter.id}
        expect(flash[:success]).to eq('Newsletter deleted successfully')
        expect(assigns(:newsletter).destroyed?).to be(true)
        expect(response).to redirect_to(newsletters_path(type: newsletter.newsletter_type))
      end
    end

    context 'GET test_mail' do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      
      it 'should render test mail template' do
        get :test_mail, {id: newsletter}
        expect(response).to render_template('test_mail')
      end
    end

    context 'POST test_mail' do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      
      before :each do
        ActionMailer::Base.deliveries = []
      end

      it 'should send test mail to email ids passed to it' do
        post :send_test_mail, {id: newsletter.id, email: {email_id: 'pamela@joshsoftware.com,winona@joshsoftware.com'}}

        expect(flash[:notice]).to eq('You will receive newsletter on the given email ids shortly.')
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.subject).to eq(newsletter.subject)
        expect(ActionMailer::Base.deliveries.first.to.count).to eq(2)
        expect(response).to redirect_to(newsletters_path(type: 'Monthly Newsletter'))
      end

      it 'should fail if not email ids passed to it' do
        post :send_test_mail, {id: newsletter.id, email: {email_id: ''}}

        expect(flash[:error]).to eq('Atleast one email ID is expected.')
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        expect(response).to render_template('test_mail')
      end
    end

    context 'POST send_newsletter' do
      before :each do
        @new_user = FactoryGirl.create(:user, is_subscribed: false, sidekiq_status: 'new user')
        @subscribed = FactoryGirl.create(:user, is_subscribed: true, sidekiq_status: 'Subscribed')
        @unsubscribed = FactoryGirl.create(:user, is_subscribed: false, sidekiq_status: 'Unubscribed')
        @date = Date.today.strftime('%Y%m')
        @sent_on_date = DateTime.now
        ActionMailer::Base.deliveries = []
      end

      it 'should send monthly newsletter to subscribed users only ' +
         'and update the sent_on attribute for user and newsletter' do
        Sidekiq::Testing.inline! do
          @monthly = FactoryGirl.create(:newsletter, sent_on: [])
          post :send_newsletter, {id: @monthly.id}

          expect(flash[:notice]).to eq('Sent Monthly newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@monthly.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@subscribed.email_id])
          expect(@monthly.reload.users_count).to eq(1)
          expect(@subscribed.reload.sent_on).to include(@date)
          expect(@unsubscribed.reload.sent_on.empty?).to eq(true)
          expect(@new_user.reload.sent_on.empty?).to eq(true)
          expect(response).to redirect_to(newsletters_path(type: @monthly.newsletter_type))
        end
      end

      it 'should send opt-in newsletter to new users only ' +
         'and update necessary attributes for user and newsletter' do
        Sidekiq::Testing.inline! do
          @opt_in = FactoryGirl.create(:newsletter, sent_on: [], newsletter_type: 'Opt-In Letter')
          post :send_newsletter, {id: @opt_in.id}

          expect(flash[:notice]).to eq('Sent Opt-In newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@opt_in.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@new_user.email_id])
          expect(@opt_in.reload.users_count).to eq(1)
          expect(@new_user.reload.sent_on).to include(@date)
          expect(@subscribed.reload.sent_on.empty?).to eq(true)
          expect(@unsubscribed.reload.sent_on.empty?).to eq(true)
          expect(@new_user.sidekiq_status).to eq('Opt in mail sent')
          expect(@new_user.opt_in_mail_sent_at).to be > @sent_on_date
          expect(response).to redirect_to(newsletters_path(type: @opt_in.newsletter_type))
        end
      end

      it 'should send opt-out newsletter to new users only ' +
         'and update necessary attributes for user and newsletter' do
        Sidekiq::Testing.inline! do
          @opt_out = FactoryGirl.create(:newsletter, sent_on: [], newsletter_type: 'Opt-Out Letter')
          post :send_newsletter, {id: @opt_out.id}
          
          expect(flash[:notice]).to eq('Sent Opt-Out newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@opt_out.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@new_user.email_id])
          expect(@opt_out.reload.users_count).to eq(1)
          expect(@new_user.reload.sent_on).to include(@date)
          expect(@subscribed.reload.sent_on.empty?).to eq(true)
          expect(@unsubscribed.reload.sent_on.empty?).to eq(true)
          expect(@new_user.sidekiq_status).to eq('Subscribed')
          expect(@new_user.subscribed_at).to be > @sent_on_date
          expect(@new_user.is_subscribed).to eq(true)
          expect(response).to redirect_to(newsletters_path(type: @opt_out.newsletter_type))
        end
      end
    end
  end
end
