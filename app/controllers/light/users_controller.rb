require_dependency 'light/application_controller'
module Light
  class UsersController < ApplicationController
    respond_to :js, :json, :html
    before_filter :user_with_token, only: [:remove, :unsubscribe, :subscribe]
    before_filter :load_user, only: [:show, :edit, :update, :destroy]

    def index
      offset_val = params[:offset] || 0
      limit_val = params[:limit] || 1000
      @users = Light::User.all.offset(offset_val).limit(limit_val)
      respond_with do |format|
        format.json { render json: @users }
      end
    end

    def show
    end

    def new
      @user = Light::User.new
    end

    def create
      @user = Light::User.new(users_params)
      @user.sent_on = Array.new
      if @user.save
        @user.update(source: 'Manual', sent_on: Array.new, sidekiq_status: 'new user' )
        flash[:success] = 'User created successfully'
        redirect_to users_path
      else
        flash[:error] = 'Error while creating user'
        render action: 'new'
      end
    end

    def unsubscribe
      if @user.present? && @user.sidekiq_status == 'Subscribed'
        @user.update(
          is_subscribed: 'false',
          unsubscribed_at: DateTime.now,
          sidekiq_status: 'Unsubscribed'
        )
        @message = 'Unsubscribed successfully!!'
      else
        @message = response_message('unsubscribed')
      end
    end

    def subscribe
      if @user.present? && @user.sidekiq_status == 'Unsubscribed'
        @user.update(
          is_subscribed: 'true',
          sidekiq_status: 'Subscribed',
          subscribed_at: DateTime.now,
          remote_ip: request.remote_ip,
          user_agent: request.env['HTTP_USER_AGENT']
        )
        @message = 'Subscribed successfully!!'
      else
        @message = response_message('subscribed')
      end
    end

    def edit
    end

    def update
      if @user && @user.update_attributes(users_params)
        flash[:success] = 'User info updated successfully'
        redirect_to users_path
      else
        flash[:error] = 'Error while updating user'
        render action: 'edit'
      end
    end

    def destroy
      if @user && @user.destroy
        flash[:success] = 'User deleted successfully'
      else
        flash[:error] = 'Error while deleting user'
      end
      redirect_to users_path
    end

    def remove
      if @user.present?
        @user.destroy
        @message = 'We have removed you from our database!'
      else
        @message = 'No user with this token exists!'
      end
    end

    def import
      if request.post?
        current_user = current_user || nil # Need this bcz current_user is not exists in engine
        message = Light::User.import(params[:file], current_user.try(&:email)).first
        flash[message.first] = message.last
      end
      render action: :import
    end

    def auto_opt_in
      @user = Light::User.new
      @newsletters  = Light::Newsletter.all.desc(:sent_on)
    end

    def opt_in
      @user = Light::User.where(email_id: params[:email]).first
      if @user.present?
        @user.update_attributes(
          is_subscribed: true,
          sidekiq_status: 'Subscribed',
          subscribed_at: DateTime.now
        )
      else
        u_name = params[:username].blank? ? params[:email] : params[:username]
        @user = Light::User.new(
          username: u_name,
          email_id: params[:email],
          source: 'web subscription request',
          subscribed_at: DateTime.now,
          sidekiq_status: 'Subscribed'
        )
      end
      respond_to do |format|
        format.json {head :no_content}
        format.html {redirect_to main_app.users_thank_you_path}
      end
    end

    def thank_you

    end

    private
    def users_params
      params.require(:user).permit(:id, :email_id, :is_subscribed, :joined_on, :source, :username)
    end

    def user_with_token
      @user = Light::User.where(token: params[:token]).first
    end

    def dummy_token?
      params[:token] == 'test_user_dummy_id'
    end

    def response_message(status)
      if dummy_token?
        "#{status.capitalize} successfully!!"
      elsif @user.nil?
        "Hey, it seems request you are trying to access is invalid. If you have any " +
        "concerns about our newsletter's subscription, kindly get in touch with " +
        "<a href='mailto:hr@joshsoftware.com' class='email'>hr@joshsoftware.com</a>"
      else
        "You have already #{status}!!"
      end
    end

    def load_user
      @user = Light::User.find(params[:id])
    end
  end
end
