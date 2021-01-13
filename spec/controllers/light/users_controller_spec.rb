require 'rails_helper'
require 'sidekiq/testing'
module Light

  RSpec.describe UsersController, type: :controller do

    routes { Light::Engine.routes}

    context 'Get index' do
      it 'list of user email' do
        get :index
        expect(response).to render_template('index')
      end
    end

    context 'GET show' do
      let(:user) {FactoryGirl.create(:user)}

      it 'show the details of the users' do
        get :show, {id: user.id}
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template('show')
      end
    end

    context 'GET new' do
      let(:new_user) {FactoryGirl.attributes_for(:user)}

      it 'display new form for adding user' do
        get :new, {user: new_user}
        expect(assigns(:user).new_record?).to eq(true)
        expect(response).to render_template('new')
      end
    end

    context 'POST create' do
      context 'creates new user' do
        before(:each) do
          user = FactoryGirl.build(:user).attributes
          @create_params = user.slice('email_id', 'username')
        end

        it 'redirects to users path' do
          post :create, {user: @create_params}

          user = Light::User.last
          expect(flash[:success]).to eq('User created successfully')
          expect(Light::User.count).to eq(1)
          expect(user.email_id).to eq(@create_params['email_id'])
          expect(user.username).to eq(@create_params['username'])
          expect(response).to redirect_to(users_path)
        end

        it 'default status is new user and is_subscribed is false' do
          post :create, {user: @create_params}
          user = User.find_by(email_id: @create_params['email_id'])
          expect(flash[:success]).to eq('User created successfully')
          expect(user.sidekiq_status).to eq 'new user'
          expect(user.source).to eq 'Manual'
          expect(user.is_subscribed).to eq false
        end
      end

      it 'not arise' do
        post :create, {user: {email_id: '', username: 'kanhaiya', is_subscribed: false}}
        expect(flash[:error]).to eq('Error while creating user')
        expect(response).to render_template('new')
      end
    end

    context 'GET edit' do
      let(:new_user) {FactoryGirl.create(:user)}

      it 'fetches the specific user record' do
        get :edit, {id: new_user.id}
        expect(assigns(:user)).to eq(new_user)
        expect(response).to render_template('edit')
      end
    end


    context 'DELETE delete' do
      let(:user) {FactoryGirl.create(:user)}

      it 'delete an user success' do
        delete :destroy, {id: user.id}
        expect(flash[:success]).to eq('User deleted successfully')
        expect(Light::User.count).to eq(0)
        expect(assigns(:user).destroyed?).to be(true)
        expect(response).to redirect_to(users_path)
      end
    end

    context 'GET remove' do
      let(:user) {FactoryGirl.create(:user)}
      
      it 'remove an user success' do
        delete :remove, {token: user.token}
        
        expect(Light::User.count).to eq(0)
        expect(assigns(:user).destroyed?).to be(true)
        expect(assigns(:message)).to eq('We have removed you from our database!')
      end

      it 'remove an user failure' do
        delete :remove, {token: 'dummy_token'}
        expect(assigns(:message)).to eq('No user with this token exists!')
      end
    end

    context 'PUT update' do
      let(:new_user) {FactoryGirl.create(:user)}

      it 'updates details of specified user' do
        patch :update, {id: new_user.id, user: {username: 'kanhaiya'}}

        expect(flash[:success]).to eq('User info updated successfully')
        expect(new_user.reload.username).to eq('kanhaiya')
        expect(response).to redirect_to(users_path)
      end

      it 'not arise' do
        put :update, {id: new_user.id, user: { email_id: ''}}
        expect(flash[:error]).to eq('Error while updating user')
        expect(response).to render_template('edit')
      end
    end

    context 'GET subscribe' do
      let(:user) {FactoryGirl.create(:user)}

      it 'should update the status to Subscribe if user is Unsubscribed' do
        user.update_attributes(sidekiq_status: 'Unsubscribed')      
        get :subscribe, {token: user.token}

        expect(user.reload.sidekiq_status).to eq('Subscribed')
        expect(user.is_subscribed).to eq(true)
        expect(assigns(:message)).to eq('Subscribed successfully!!')
        expect(response).to render_template('subscribe')
      end

      it 'should send appropriate message if user is already subscribed' do
        user.update_attributes(sidekiq_status: 'Subscribed')        
        get :subscribe, {token: user.token}

        expect(user.reload.sidekiq_status).to eq('Subscribed')
        expect(user.is_subscribed).to eq(true)
        expect(assigns(:message)).to eq('You have already Subscribed!!')
        expect(response).to render_template('subscribe')
      end

      it 'should send appropriate message if token is dummy' do
        get :subscribe, {token: 'test_user_dummy_id'}

        expect(assigns(:message)).to eq('Subscribed successfully!!')
        expect(assigns(:user).present?).to eq(false)
        expect(response).to render_template('subscribe')
      end

      it 'should send appropriate message if token is invalid' do
        response_msg = 'Hey, it seems request you are trying to access is invalid. If you have any ' +
          'concerns about our newsletters subscription, kindly get in touch with ' +
          "<a href='mailto:hr@joshsoftware.com' class='email'>hr@joshsoftware.com</a>"
        get :subscribe, {token: 'invalid token'}

        expect(assigns(:message)).to eq(response_msg)
        expect(assigns(:user).present?).to eq(false)
        expect(response).to render_template('subscribe')
      end
    end

    context 'GET unsubscribe' do
      let(:user) {FactoryGirl.create(:user)}

      it 'should update the status to Subscribe if user is Unsubscribed' do
        user.update_attributes(sidekiq_status: 'Subscribed')      
        get :unsubscribe, {token: user.token}

        expect(user.reload.sidekiq_status).to eq('Unsubscribed')
        expect(user.is_subscribed).to eq(false)
        expect(assigns(:message)).to eq('Unsubscribed successfully!!')
        expect(response).to render_template('unsubscribe')
      end

      it 'should send appropriate message if user is already subscribed' do
        user.update_attributes(sidekiq_status: 'Unsubscribed')        
        get :unsubscribe, {token: user.token}

        expect(user.reload.sidekiq_status).to eq('Unsubscribed')
        expect(user.is_subscribed).to eq(true)
        expect(assigns(:message)).to eq('You have already Unsubscribed!!')
        expect(response).to render_template('unsubscribe')
      end

      it 'should send appropriate message if token is dummy' do
        get :unsubscribe, {token: 'test_user_dummy_id'}

        expect(assigns(:message)).to eq('Unsubscribed successfully!!')
        expect(assigns(:user).present?).to eq(false)
        expect(response).to render_template('unsubscribe')
      end

      it 'should send appropriate message if token is invalid' do
        response_msg = 'Hey, it seems request you are trying to access is invalid. If you have any ' +
          "concerns about our newsletter's subscription, kindly get in touch with " +
          "<a href='mailto:hr@joshsoftware.com' class='email'>hr@joshsoftware.com</a>"
        get :unsubscribe, {token: 'invalid token'}

        expect(assigns(:message)).to eq(response_msg)
        expect(assigns(:user).present?).to eq(false)
        expect(response).to render_template('unsubscribe')
      end
    end

    context 'GET import' do
      it 'should render import template' do
        get :import
        expect(response).to render_template('import')
      end
    end

    context 'POST import ' do
      context 'data from file import_users.csv' do
        let(:file) { Rack::Test::UploadedFile.new("#{Rails.root}/files/import_users.csv", 'text/csv') }
        let!(:existing_user) {
          create :user,
          username: 'Winona Bayer',
          email_id: 'winona@gmail.com',
          is_subscribed: false
        }

        it 'File to be imported should contain following data ' do
          users = [
            ['Full Name', 'Email'],
            ['Miss Pamela Kovacek','pamela@gmail.com'],
            [nil, 'claud@gmail.com'],
            ['Delmer Botsford', nil],
            ['Winona Bayer', 'winona@gmail.com']
          ]
          expect(User.find_by(email_id: users.last.last)).to be_present
          rows = CSV.read(file.path)
          expect(users).to eq(rows)
        end

        it 'should import users with valid information' do
          post :import, file: file

          expect(flash['success']).to eq('You will get an update email.')
          expect(ImportWorker.jobs.size).to eq(1)
          ImportWorker.drain
          expect(ImportWorker.jobs.size).to eq(0)
          expect(User.count).to eq(3)
          expect(User.find_by(email_id: 'pamela@gmail.com')).to be_present

          existing_user.reload
          expect(existing_user).to be_present
          expect(existing_user.is_subscribed).to eq(false)

          user = User.find_by(email_id: 'claud@gmail.com')
          expect(user).to be_present
          expect(user.is_subscribed).to eq(false)
          expect(user.sidekiq_status).to eq('new user')
          expect(user.source).to eq('Business Card')
          expect(user.username).to eq(user.email_id) # Since username is empty we are storing email id in username
        end

      end
      
      context 'should return success if' do
        after do
          file = Rack::Test::UploadedFile.new(@file_path, 'text/csv')
          post :import, file: file

          expect(flash['success']).to eq('You will get an update email.')
          expect(ImportWorker.jobs.size).to eq(1)
          ImportWorker.drain
          expect(ImportWorker.jobs.size).to eq(0)
          expect(User.count).to eq(3)
          expect(User.find_by(email_id: 'pamela@gmail.com')).to be_present
        end

        it 'header contains spaces before or after name' do
          @file_path = "#{Rails.root}/files/import_with_spaces_in_header.csv"
        end

        it 'header mismatch the letter case i.e. "full name" istead of Full Name' do
          @file_path = "#{Rails.root}/files/import_header_case_insensitive.csv"
        end

        it 'contain extra columns in csv' do
          @file_path = "#{Rails.root}/files/import_with_extra_columns.csv"
        end
      end

      context 'should raise error if' do
        it "headers doesn't match" do
          User.destroy_all
          file2 = Rack::Test::UploadedFile.new("#{Rails.root}/files/import_without_header.csv", 'text/csv')
          post :import, file: file2
          expect(flash['error']).to eq("Header doesn't matches")
          expect(User.all).to be_empty
        end

        it "headers doesn't match" do
          User.destroy_all
          file2 = Rack::Test::UploadedFile.new("#{Rails.root}/files/contacts.txt")
          post :import, file: file2
          expect(flash[:error]).to eq('Please select CSV file')
          expect(User.all).to be_empty
        end
      end
    end
  end
end
