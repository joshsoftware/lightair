require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  
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
end
