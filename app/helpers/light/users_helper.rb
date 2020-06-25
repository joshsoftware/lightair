module Light
  module UsersHelper
    def dummy_token?
      params[:token] == 'test_user_dummy_id'
    end
  end
end
