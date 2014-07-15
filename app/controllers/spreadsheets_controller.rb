class SpreadsheetsController < ApplicationController
  require 'google'
  include Google::Spreadsheets

  def index
    @spreadsheets = Spreadsheet.all.to_a
  end

  def new
    if params[:access_token]
      spreadsheet = Spreadsheet.where(access_token: params['access_token'])[0]
    else
      spreadsheet = Spreadsheet.new
      spreadsheet.add_tokens(request.env['omniauth.auth'].fetch('credentials'))
    end

    if spreadsheet.save
      # Spreadsheets from google
      @spreadsheets = list(spreadsheet)
      @token        = spreadsheet.access_token
    else
      # Handle if data does not get saved
      @msg = 'Getting same access token. Try deleting '
    end
  end

  def edit
    token = spreadsheet_params['token']
    spreadsheet = Spreadsheet.where(access_token: token)[0]

    if spreadsheet && spreadsheet.add_spreadsheet_credentials(spreadsheet_params)
      spreadsheet.save
    else
      @error = 'Already Present'
    end

    @spreadsheets = Spreadsheet.all.to_a

    render action: 'index'
  end

  def update
    spreadsheet = Spreadsheet.find(params['id'])
    @worksheet  = worksheets(spreadsheet)
    @fails = User.add_users_from_worksheet(@worksheet, 2)
    #redirect_to users_path(fails: User.add_users_from_worksheet(@worksheet))
  end

  def destroy
    Spreadsheet.find(params['id']).delete
    redirect_to spreadsheets_path
  end

  def failure
    if params['message'].match('access_denied')
      @msg = 'Account integration Failed. User Refused to grant permissions'
    end
    @spreadsheets = Spreadsheet.all.to_a
    render action: 'index'
  end

  #################################
  private
  #################################

    def spreadsheet_params
      params.permit(:id, :title, :token)
    end
end
