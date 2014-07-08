class HomeController < ApplicationController
  def index
  end

  def add_from_google
    @sheets                             =  Token.first
    @client                             = Google::APIClient.new
    @client.authorization.access_token  = @sheets['access_token']
    @client.authorization.client_id     = ENV["GOOGLE_ID"]
    @client.authorization.client_secret = ENV["GOOGLE_KEY"]
    @client.authorization.refresh_token = @sheets["refresh_token"]
    @re                                 = @client.auto_refresh_token
    #session     = GoogleDrive.login_with_oauth(tkn["access_token"])
    drive                               = @client.discovered_api('drive', 'v2')

    @wks                                = @client.execute( 
                                            api_method: drive.files.watch, 
                                            parameters: {fileId: @sheets["spreadsheet_id"]},
                                            headers: {'Content-Type'=>'application/json'}
                                          )
  end
end
