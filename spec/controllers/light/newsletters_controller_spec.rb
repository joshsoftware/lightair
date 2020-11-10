require 'rails_helper'

module Light

  RSpec.describe NewslettersController, :type => :controller do

    routes { Light::Engine.routes}

    context "GET index" do
      it "list all the newsletters" do
        params = {}
        get :index, params
        expect(response).to have_http_status(:success)
      end

      it "list all the newsletters" do
        params = {type: 'Opt-In Letter'}
        get :index, params
        expect(response).to have_http_status(:success)
      end

      it "list all the newsletters" do
        params = {type: 'Opt-Out Letter'}
        get :index, params
        expect(response).to have_http_status(:success)
      end
    end

    context "GET show" do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      it "show the deatails of the newsletters" do
        get :show, {:id => newsletter.id}
        expect(assigns(:newsletter).subject).to eq(newsletter.subject)
        expect(response).to render_template("show")
      end
    end

    context "GET new" do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}
      it "display new form for adding newsletter" do
        get :new, {newsletter: new_newsletter}
        expect(response).to render_template("new")
      end
    end

    context "POST create" do
      let(:new_newsletter) {FactoryGirl.attributes_for(:newsletter)}
      it "display new form for adding newsletter" do
        post :create, {newsletter: new_newsletter}
        expect(flash[:success]).to eq('Newsletter created successfully')
        expect(response).to redirect_to(newsletters_path(type: 'Monthly Newsletter'))
      end

      it "create a newsletter failure" do
        post :create, {newsletter: {content: "",sent_on: "2014-1-1", users_count: 0}}
        expect(flash[:error]).to eq('Error while creating newsletter')
        expect(response).to render_template("new")
      end
    end

    context "GET edit" do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}
      it "fetches the specific newsletter" do
        get :edit, {id: new_newsletter.id}
        expect(response).to render_template("edit")
      end
    end

    context "PUT update" do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}
      it "updates details of specified newsletter" do
        put :update, {id: new_newsletter.id, newsletter: {content: new_newsletter.content}}
        expect(flash[:success]).to eq('Newsletter updated successfully')
        expect(response).to redirect_to(newsletters_path(type: new_newsletter.newsletter_type))
      end

      it "update a newsletter failure" do
        put :update, {id: new_newsletter.id, newsletter: {content: ""}}
        expect(flash[:error]).to eq('Error while updating newsletter')
        expect(response).to render_template("edit")
      end
    end

    context 'DELETE delete' do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      it 'delete a newsletter success' do
        delete :destroy, {id: newsletter.id}
        expect(flash[:success]).to eq('Newsletter deleted successfully')
        expect(response).to redirect_to(newsletters_path(type: newsletter.newsletter_type))
      end

      it 'delete a newsletter failure' do
        delete :destroy, {id: 0}
        expect(flash[:error]).to eq('Error while deleting newsletter')
        expect(response).to redirect_to(newsletters_path)
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

      it 'should fail if newsletter not found' do
        post :send_test_mail, {id: 0, email: {email_id: 'test@joshsoftware.com'}}
        expect(flash[:error]).to eq('Newsletter not found.')
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        expect(response).to redirect_to(newsletters_path)
      end
    end

    describe 'POST send_newsletter' do
      before :each do
        @new_user = FactoryGirl.create(:user, is_subscribed: false)
        @subscribed = FactoryGirl.create(:user, is_subscribed: true, sidekiq_status: 'Subscribed')
        @unsubscribed = FactoryGirl.create(:user, is_subscribed: false, sidekiq_status: 'Unubscribed')
        @monthly = FactoryGirl.create(:newsletter, sent_on: [])
        @opt_in = FactoryGirl.create(:newsletter, sent_on: [], newsletter_type: 'Opt-In Letter')
        @opt_out = FactoryGirl.create(:newsletter, sent_on: [], newsletter_type: 'Opt-Out Letter')
        @date = Date.today.strftime("%Y%m")
        @sent_on_date = DateTime.now
        ActionMailer::Base.deliveries = []
      end

      it 'should fail if newsletter not found' do
        post :send_newsletter, {id: 0}
        expect(flash[:error]).to eq('Newsletter not found.')
        expect(response).to redirect_to(newsletters_path)
      end

      it 'should send monthly newsletter to subscribed users only' +
        'and update the sent_on attribute for user and newsletter' do
        Sidekiq::Testing.inline! do
          post :send_newsletter, {id: @monthly.id}
          @subscribed.reload
          @monthly.reload
          expect(flash[:notice]).to eq('Sent Monthly newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@monthly.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@subscribed.email_id])
          expect(@monthly.users_count).to eq(1)
          expect(@subscribed.sent_on).to include(@date)
          expect(response).to redirect_to(newsletters_path(type: @monthly.newsletter_type))
        end
      end

      it 'should send opt-in newsletter to new users only' +
        'and update necessary attributes for user and newsletter' do
        Sidekiq::Testing.inline! do
          post :send_newsletter, {id: @opt_in.id}
          @new_user.reload
          @opt_in.reload
          expect(flash[:notice]).to eq('Sent Opt-In newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@opt_in.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@new_user.email_id])
          expect(@opt_in.users_count).to eq(1)
          expect(@new_user.sent_on).to include(@date)
          expect(@new_user.sidekiq_status).to eq('Opt in mail sent')
          expect(@new_user.opt_in_mail_sent_at).to be > @sent_on_date
          expect(response).to redirect_to(newsletters_path(type: @opt_in.newsletter_type))
        end
      end

      it 'should send opt-out newsletter to new users only' +
        'and update necessary attributes for user and newsletter' do
        Sidekiq::Testing.inline! do
          post :send_newsletter, {id: @opt_out.id}
          @new_user.reload
          @opt_out.reload
          expect(flash[:notice]).to eq('Sent Opt-Out newsletter successfully')
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to eq(@opt_out.subject)
          expect(ActionMailer::Base.deliveries.first.to).to eq([@new_user.email_id])
          expect(@opt_out.users_count).to eq(1)
          expect(@new_user.sent_on).to include(@date)
          expect(@new_user.sidekiq_status).to eq('Subscribed')
          expect(@new_user.subscribed_at).to be > @sent_on_date
          expect(@new_user.is_subscribed).to eq(true)
          expect(response).to redirect_to(newsletters_path(type: @opt_out.newsletter_type))
        end
      end
    end
  end
end
