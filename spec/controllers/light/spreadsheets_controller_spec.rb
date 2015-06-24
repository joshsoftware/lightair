require 'rails_helper'
require 'webmock/rspec'
require 'vcr'
module Light
=begin
  RSpec.describe SpreadsheetsController, :type => :controller do

    routes { Light::Engine.routes}
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
      let(:sheet) { FactoryGirl.create(:spreadsheet)}
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

      it 'does not creates new spreadsheet when access_token is given' do
        VCR.use_cassette 'controllers/api-response' do
          get(:new, access_token: sheet.access_token)
          expect(response).to render_template(:new)
        end
      end

      it 'does not creates new spreadsheet if access_token already present' do
        sheet

        VCR.use_cassette 'controllers/api-new_tokens' do
          request.env['omniauth.auth'] = {
            'credentials'       => {
              'token'         => sheet[:access_token],
              'refresh_token' => sheet[:refresh_token],
              'expires_at'    => Time.now,
              'expires'       => true
            }
          }
          get :new
          expect(assigns(:msg)).not_to be(nil)
        end
      end
    end

    context 'Get Edit' do
      let(:sheet) { FactoryGirl.create(:spreadsheet)}
      it 'renders index page after executing' do
        get :edit, id: sheet['spreadsheet_id'], title: sheet['spreadsheet_title'], token: sheet['access_token']

        expect(response).to render_template(:index)
      end

      it 'adds spreadsheet\'s credentials' do
        sheet
        Spreadsheet.delete_all
        spreadsheet = Spreadsheet.new
        spreadsheet.add_tokens({
          'token'         => sheet[:access_token],
          'refresh_token' => sheet[:refresh_token],
          'expires_at'    => sheet[:expires_at]
        })
        spreadsheet.save
        get :edit, id: sheet['spreadsheet_id'], title: sheet['spreadsheet_title'], token: sheet['access_token']
        expect(assigns(:error)).to be(nil)
      end

      it 'does not add duplicate spreadsheet' do
        sheet
        spreadsheet = Spreadsheet.new
        spreadsheet.add_tokens({
          'token'         => '0ya29.QgC-kYKwAzcdh8AAABnuwXicpaXRvO_YSlv4V9J556542KazsYWEia63TlRyA',
          'refresh_token' => sheet[:refresh_token],
          'expires_at'    => sheet[:expires_at]
        })
        spreadsheet.save

        get :edit, title: sheet['spreadsheet_title'], id: sheet['spreadsheet_id'], token: '0ya29.QgC-kYKwAzcdh8AAABnuwXicpaXRvO_YSlv4V9J556542KazsYWEia63TlRyA'

        expect(assigns(:error)).not_to be(nil)
      end

    end

    context 'Post Update' do
      let(:sheet) { FactoryGirl.create(:spreadsheet)}
      it 'updates the spreadsheet' do
        VCR.use_cassette 'controllers/api-update-with-data', record: :new_episodes do
          post :update, id: sheet
          expect(response).to render_template(:update)
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
=end
end
