module GoogleSpreadsheets
  def get_spreadsheets(spreadsheet)
    #binding.pry
    if Time.now > spreadsheet['expires_at']
      spreadsheet    = refresh_token spreadsheet
    end

    client      = Google::APIClient.new
    client.authorization.access_token = spreadsheet.access_token
    drive       = client.discovered_api('drive', 'v2')

    wks         = client.execute(
                      api_method: drive.files.list,
                      parameters: {},
                      headers:    {'Content-Type' => 'application/json'}
                  )
    (JSON.parse(wks.data.to_json))['items']
  end

  def get_worksheets(spreadsheet, i = 0)
    if Time.now > spreadsheet['expires_at']
      spreadsheet    = refresh_token spreadsheet
    end

    session   = GoogleDrive.login_with_oauth(spreadsheet['access_token'])
    session.spreadsheet_by_key(spreadsheet['spreadsheet_id']).worksheets[i]
  end

  def refresh_token(spreadsheet)
    data = {
        client_id:      ENV['GOOGLE_ID'],
        client_secret:  ENV['GOOGLE_KEY'],
        refresh_token:  spreadsheet['refresh_token'],
        grant_type:     'refresh_token'
    }
    re = ActiveSupport::JSON.decode(RestClient.post 'https://accounts.google.com/o/oauth2/token', data)

    #sheets                 = Token.where(spreadsheet_id: spreadsheet['spreadsheet_id'])[0]
    spreadsheet['access_token'] = re['access_token']
    spreadsheet['expires_at']   = (Time.now + re['expires_in'].second).localtime
    #binding.pry
    spreadsheet.save

    spreadsheet
  end
end