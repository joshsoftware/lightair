require 'rails_helper'
require 'webmock/rspec'

RSpec.describe SpreadsheetsController, :type => :controller do
  google_auth_response = File.new('spec/controllers/google_auth_response.json')
  context 'GET Index' do
    it 'it renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'should return all the spreadhseets' do
      c = SpreadsheetsController.new
      r = c.instance_eval{index}
      expect(r.count).to eq(Spreadsheet.count)
    end
  end

  context 'GET New' do
    it 'opens authentication page on calling auth/google' do
      stub_request(:get, 'http://localhost:8080/auth/google/').to_return(google_auth_response)
      stub_request(:get, "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=367225507767-119uvbhdadqbft2kn4759rodoiivksn9.apps.googleusercontent.com&prompt=consent&redirect_uri=http://localhost:8080/auth/google/callback&response_type=code&scope=https://www.googleapis.com/auth/userinfo.profile%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/drive%20https://spreadsheets.google.com/feeds&state=df37c7da59cf8f7a4899cd5a67a612e9d18946664bc98d4f").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Cookie'=>'_lightair_session=Uy9SNDQ1LzZFandLd1g4S2VVTEptR3ZRa0RBcnNFWGtZbG1VZmNKMzc5Z1F6cDFuaHBCa2lScHcxL1FBQ044RTJZMU9iUWF2UitaVjQxcGVzeUZwS0Q3NkdXdzg2SHB6S0IrcU1sR2ExelhRRVZuWFF6MFpraktBMTNCcTM4UVZ5a01ReitYSzNYT2M0dXR1NWViUjhvVGVxUnYwRUtLREtoQUVjMkJPMW1PZG14MUVUQlN0Q2hkRUh5blVLMDZRLS1OZ3JGQXFWQmJKMGNCWGszQWoyMkNRPT0=--8345e9f7215c9ef812febd3588c505cfaef628c1', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})

      RestClient.get('http://localhost:8080/auth/google/')
    end
  end
end
