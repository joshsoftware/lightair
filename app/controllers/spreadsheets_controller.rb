class SpreadsheetsController < ApplicationController
  include GoogleSpreadsheets

  def index
    @spreadsheets = Spreadsheet.all.to_a
  end

  def new
    @req = params
=begin
    if params[:access_token]
      spreadsheet = Spreadsheet.where(access_token: params['access_token'])[0]
    else
      spreadsheet = Spreadsheet.new
      spreadsheet.add_tokens(request.env['omniauth.auth'].fetch('credentials'))
    end

    if spreadsheet.save
      # Spreadsheets from google
      @spreadsheets = get_spreadsheets(spreadsheet)
      @token        = spreadsheet.access_token
      @msg          = 'work'
    else
      @msg          = 'no work'
      # Handle if data does not get saved
    end
=end
  end

  def edit
    token = spreadsheet_params['token']
    spreadsheet = Spreadsheet.where(access_token: token)[0]
    spreadsheet.add_spreadsheet_credentials(spreadsheet_params)
    #binding.pry
    spreadsheet.save

    @spreadsheets = Spreadsheet.all.to_a

    render action: 'index'
  end

  def update
    spreadsheet = Spreadsheet.find(params['id'])
    @worksheet  = get_worksheets(spreadsheet)
    User.add_users_from_worksheet(@worksheet)
    redirect_to users_path
  end

  def destroy
    Spreadsheet.find(params['id']).delete
    redirect_to spreadsheets_path
  end

  def spreadsheet_params
    params.permit(:title, :id, :token)
  end
end
