require 'rails_helper'
require 'webmock/rspec'
require 'vcr'

RSpec.describe SpreadsheetsController, :type => :controller do

  context 'GET User Permission' do
    context 'User accepts' do
      it 'redirects to new ' do
        VCR.use_cassette 'controllers/api-permissions' do
          data = {
              name:                 'google',
              scope:                'userinfo.profile,userinfo.email,drive,https://spreadsheets.google.com/feeds',
              prompt:               'consent',
              access_type:          'offline',
              redirect_uri:         'http://localhost:8080/auth/google/callback'
          }
          RestClient.post 'https://accounts.google.com/o/oauth2/auth', data
        end

      end
    end
  end

  context 'GET Index' do
    it 'it renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'should return all the spreadhseets' do
      sheet
      get :index
      expect(assigns(:spreadsheets)).equal?(Spreadsheet.all.to_a.count)
    end
  end

  context 'GET New' do
    it 'creates new spreadsheet when no access_token given' do
      VCR.use_cassette 'controllers/api-new_tokens' do
        request.env['omniauth.auth'] = {
            'credentials' => {
              'token' => 'ya29.QgC-5kYKwAzcdh8AAABnuwXicpaXRvO_YSlv4V9J556542KazsYWEia63TlRyA',
              'refresh_token' => '1/DlAqfSUji69F3YuVAHSoWxWE0grR8aYSkb2OocVCNBw',
              'expires_at' => Time.now,
              'expires' => true
          }
        }

        get :new
        expect(response).to render_template(:new)
      end
    end

    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'does not creates new spreadsheet when access_token is given' do
      VCR.use_cassette 'controllers/api-response' do
        get(:new, access_token: sheet.access_token)
        expect(response).to render_template(:new)
      end
    end
  end

  context 'Get Edit' do
    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'renders index page after executing' do
      get :edit, title: 'namecollection', id: sheet['spreadsheet_id'], token: sheet['access_token']

      expect(response).to render_template(:index)
    end

    it 'adds spreadsheet\'s credentials' do
      get :edit, title: 'namecollection', id: sheet['spreadsheet_id'], token: sheet['access_token']
      expect(assigns(:error)).to be(nil)
    end
  end

  context 'Post Update' do
    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'updates the spreadsheet' do
      VCR.use_cassette 'controllers/api-update-with-data', record: :new_episodes do
        post :update, id: sheet
        expect(response).to redirect_to users_path
      end
    end
  end

  context 'Post Destroy' do
    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'deletes spreadsheets from database' do
      sheet
      count1 = Spreadsheet.all.count
      post :destroy, id: sheet
      count2 = Spreadsheet.all.count

      expect(count1).to be(count2 + 1)
    end

    it 'redirects to spreadsheets index page' do
      post :destroy, id: sheet
      expect(response).to redirect_to spreadsheets_path
    end
  end

  context 'Get Failure' do
    it 'renders index page when user does not accepts permissions' do
      get :failure, message: 'access_denied'

      expect(response).to render_template(:index)
    end

    it 'to give a failure message when it fails' do
      get :failure, message: 'access_denied'
      expect(assigns(:msg)).not_to be nil
    end

    it 'not to give a failure message when it does not fails' do
      get :failure, message: 'access_granted'
      expect(assigns(:msg)).to be nil
    end

    let(:sheet) { FactoryGirl.create(:spreadsheet)}
    it 'gets all the spreadsheets' do
      sheet
      get :failure, message: 'access_denied'

      expect(assigns(:spreadsheets).count).equal?(Spreadsheet.all.count)
    end
  end
end
