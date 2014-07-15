module Google
  module Spreadsheets
    def list(spreadsheet)
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

    def worksheets(spreadsheet, index = 0)
      if DateTime.now.utc > spreadsheet['expires_at']
        spreadsheet    = refresh_token spreadsheet
      end

      session   = GoogleDrive.login_with_oauth(spreadsheet['access_token'])
      session.spreadsheet_by_key(spreadsheet['spreadsheet_id']).worksheets[index]
    end

    def refresh_token(spreadsheet)
      client = Google::APIClient.new
      client.authorization.client_id = ENV['GOOGLE_ID']
      client.authorization.client_secret = ENV['GOOGLE_KEY']
      client.authorization.grant_type = 'refresh_token'
      client.authorization.refresh_token = spreadsheet['refresh_token']
      re = client.authorization.fetch_access_token!

      spreadsheet['access_token'] = re['access_token']
      spreadsheet['expires_at']   = (Time.now + re['expires_in'].second)
      spreadsheet.save

      spreadsheet
    end
  end
end