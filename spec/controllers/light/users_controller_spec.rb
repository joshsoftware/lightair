require 'rails_helper'
require 'sidekiq/testing'
module Light

  RSpec.describe UsersController, :type => :controller do

    routes { Light::Engine.routes}

    context "Get index" do
      it "list of user email" do
        get :index
        expect(response).to render_template("index")
      end
    end

    context "GET show" do
      let(:user) {FactoryGirl.create(:user)}
      it "show the details of the users" do
        get :show, {id: user.id}
        expect(response).to render_template("show")
      end
    end

    context "GET new" do
      let(:new_user) {FactoryGirl.attributes_for(:user)}
      it "display new form for adding user" do
        post :new, {user: new_user}
        expect(response).to render_template("new")
      end
    end

    context " POST create" do
      let(:new_user) {FactoryGirl.attributes_for(:user)}
      it "creates a new user" do
        post :create, {user: new_user}
        expect(response).to redirect_to(users_path)
      end
      it "not arise" do
        post :create, {user: {email_id: "",username: "kanhaiya", is_subscribed: "false"}}
        expect(response).to render_template("new")
      end
    end

    context "GET edit" do
      let(:new_user) {FactoryGirl.create(:user)}
      it "fetches the specific all the users" do
        get :edit, {id: new_user.id}
        expect(response).to render_template("edit")
      end
    end


    context "DELETE delete" do
      let(:user) {FactoryGirl.create(:user)}
      it "delete an user" do
        delete :destroy, {id: user.id}
        expect(response).to redirect_to(users_path)
      end
    end


    context "PUT update" do
      let(:new_user) {FactoryGirl.create(:user)}
      it "updates details of specified user" do
        patch :update, {id: new_user.id, user: { email_id: new_user.email_id}}
        expect(response).to redirect_to(users_path)
      end
      it " not arise" do
        put :update, {id: new_user.id, user: { email_id: ""}}
        expect(response).to render_template("edit")
      end
    end

    context "GET subscribe" do
      let(:new_user) {FactoryGirl.create(:user)}
      it "unsubcribes a particular user" do
        get :subscribe, {id: new_user.id}
        expect(response).to render_template("subscribe")
      end
    end

    context "GET sendmailer" do
      it "sends mails to user" do
        VCR.use_cassette 'controllers/user-mails', record: :new_episodes do
          get :sendmailer
          expect(response).to redirect_to(newsletters_path)
        end
      end
    end

    context "GET sendTest" do
      it "sends Test mails to user" do
        VCR.use_cassette 'controllers/user-mails', record: :new_episodes do
          get :sendtest, email: {email_id: "pankajb@joshsoftware.com"}
          expect(response).to redirect_to(newsletters_path)
        end
      end
    end

    context 'GET import' do
      it 'should render import template' do
        get :import
        expect(response).to render_template("import")
      end
    end

    context 'POST import ' do

      let(:file_path) { "#{Rails.root}/files/import_users.csv" }
      let!(:user) {create :user, username: "Winona Bayer", email_id: "winona@gmail.com"}

      it 'File to be imported should contain following data ' do
        users = [['Full Name', 'Email'],
          ["Miss Pamela Kovacek","pamela@gmail.com"], 
                 [nil, "claud@gmail.com"],
                 ["Delmer Botsford", nil],
                 ["Winona Bayer", "winona@gmail.com"],
        ]
        expect(User.find_by(email_id: users.last.last)).to be_present
        file = CSV.foreach(file_path)
        rows = file.collect{|row| row}
        expect(users).to eq(rows)
      end

      it 'should import users with valid information' do
        post :import, file: file_path
        
        expect(flash[:success]).to eq("You will get an update email.")
        expect(ImportWorker.jobs.size).to eq(1)
        ImportWorker.drain
        expect(ImportWorker.jobs.size).to eq(0)
        expect(User.count).to eq(3)
        expect(User.find_by(email_id: "pamela@gmail.com")).to be_present
        expect(User.find_by(email_id: "winona@gmail.com")).to be_present

        user = User.find_by(email_id: "claud@gmail.com")
        expect(user).to be_present
        expect(user.source).to eq("Business Card")
        expect(user.username).to eq(user.email_id) # Since username is empty we are storing email id in username

      end
      
      it "should raise error if headers doesn't match" do
        User.destroy_all
        file_path2 = "#{Rails.root}/files/import_without_header.csv" 
        post :import, file: file_path2
        expect(flash[:error]).to eq("Header doesn't matches")
        expect(User.all).to be_empty
      end
    end

  end

end
