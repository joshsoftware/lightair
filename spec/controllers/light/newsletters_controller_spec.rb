require 'rails_helper'

module Light

RSpec.describe NewslettersController, :type => :controller do

  routes { Light::Engine.routes}

  context "GET index" do
    it "list all the newsletters" do
      get :index
      expect(response).to render_template("index")
    end
  end

  context "GET show" do
    let(:newsletter) {FactoryGirl.create(:newsletter)}
    it "show the deatails of the newsletters" do
      get :show, {:id => newsletter.id}
      expect(response).to render_template("show")
    end
  end

  context "GET new" do
    let(:new_newsletter) {FactoryGirl.create(:newsletter)}
    it "display new form for adding newsletter" do
      post :new, {newsletter: new_newsletter}
      expect(response).to render_template("new")
    end
  end

  context "POST create" do
    let(:new_newsletter) {FactoryGirl.attributes_for(:newsletter)}
    it "display new form for adding newsletter" do
      post :create, {newsletter: new_newsletter}
      expect(response).to redirect_to(newsletters_path)
    end

    it "not arise" do
      post :create, {newsletter: {content: "",sent_on: "2014-1-1", users_count: 0}}
      expect(response).to render_template("new")
    end
  end

    context "GET update" do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}
      it "fetches the specific newsletter" do
        get :edit, {id: new_newsletter.id}
        expect(response).to render_template("edit")
      end
    end

    context "DELETE delete" do
      let(:newsletter) {FactoryGirl.create(:newsletter)}
      it "delete a newsletter" do
        delete :destroy, {id: newsletter.id}
        expect(response).to redirect_to(newsletters_path)
      end
    end

    context "PUT update" do
      let(:new_newsletter) {FactoryGirl.create(:newsletter)}
      it "updates details of specified newsletter" do
        put :update, {id: new_newsletter.id, newsletter: {content: new_newsletter.content}}
        expect(response).to redirect_to(newsletters_path)
      end

      it "not arise" do
        put :update, {id: new_newsletter.id, newsletter: {content: ""}}
        expect(response).to render_template("edit")
      end
    end
end

end
