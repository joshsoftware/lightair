class CallbacksController < ApplicationController

  def index
    #Token.delete_all
    tkn = Token.first

    if tkn.nil?
      redirect_to "/auth/google" and return
    else
      if tkn['spreadsheet_id'].nil?
        @ws = getSheet(tkn)
        render action: 'create'  and return
      end
    end
    @sheets = Token.all.to_a
  end

  def omniauth
    tkn                   = Token.new
    req                   = request.env["omniauth.auth"]
    auth_token            = request.env["omniauth.auth"].fetch("credentials")
    tkn["access_token"]   = auth_token.fetch("token")
    tkn["refresh_token"]  = auth_token.fetch("refresh_token")
    tkn["expires_at"]     = auth_token.fetch("expires_at")

    if tkn.save
      @ws = getSheet(tkn)
    else
      @ws = {error: "not able to save"}
    end

    render action: 'create' and return
  end

  def getSheet(tkn)
    client      = Google::APIClient.new
    client.authorization.access_token = tkn['access_token']
    #session     = GoogleDrive.login_with_oauth(tkn["access_token"])
    drive       = client.discovered_api('drive', 'v3')

    wks         = client.execute( 
                      api_method: drive.files.list, 
                      parameters: {},
                      headers: {'Content-Type'=>'application/json'}
                    )
    JSON.parse(wks.data.to_json)
  end

  def setSheet
    tkn = Token.first
    tkn['spreadsheet_id'] = params['id']
    tkn.save

    insertEmailInDatabase(tkn)

    redirect_to users_path
  end

  def insertEmailInDatabase(tkn)
    @tkn     = tkn
    session  = GoogleDrive.login_with_oauth(@tkn["access_token"])
    @ws      = session.spreadsheet_by_key(@tkn['spreadsheet_id']).worksheets[0]

    rowcount  = @ws.rows.count
    usercount = User.count
    #if rowcount > usercount
      (rowcount).times do |i|
        User.create(email_id:       @ws[i + 1, 1], # + usercount, 1],
                    is_subscribed:  true, 
                    joined_on:      Date.today, 
                    source:         "Google Spreadsheet")
      end
    #end

    #render action: "test"
  end

  def refresh_token(tkn)
    data = {
        client_id:      ENV['GOOGLE_ID'],
        client_secret:  ENV['GOOGLE_KEY'],
        refresh_token:  tkn['refresh_token'],
        grant_type:     'refresh_token'
    }
    re = ActiveSupport::JSON.decode(RestClient.post 'https://accounts.google.com/o/oauth2/token', data)
=begin
    client      = Google::APIClient.new
    client.authorization.access_token = tkn['access_token']
    client.authorization.client_id = ENV["GOOGLE_ID"]
    client.authorization.client_secret = ENV["GOOGLE_KEY"]
    client.authorization.refresh_token = tkn["refresh_token"]
    re = client.authorization.update_token!
=end
    sheets                 = Token.where(spreadsheet_id: tkn['spreadsheet_id'])[0]
    sheets['access_token'] = re['access_token']
    sheets['expires_at']   = (Time.now + re['expires_in'].second).localtime
    sheets.save

    re
  end

  def update
    tkn       = Token.where(spreadsheet_id: params['id'])
    @tkn = tkn[0]
    unless Time.now > tkn[0]['expires_at']
      @ref    = refresh_token tkn[0]
    end
    tkn       = Token.where(spreadsheet_id: params['id'])
    insertEmailInDatabase(tkn[0])
    redirect_to users_path
    #render action: 'test'
  end

end
