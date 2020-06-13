require_dependency "light/application_controller"
module Light
  class UsersController < ApplicationController
    respond_to :js, :json, :html
    before_filter :user_with_token, only: [:remove, :unsubscribe, :subscribe]

    def index
      offset_val = params[:offset] || 0
      limit_val = params[:limit] || 500
      @users = Light::User.all.offset(offset_val).limit(limit_val)
      respond_with do |format|
        format.json   { render json: @users }
      end
    end

    def show
      @user = Light::User.find(params[:id])
    end

    def new
      @user = Light::User.new
    end

    def create
      @user = Light::User.new(users_params)
      @user.sent_on = Array.new
      if @user.save
        @user.update(source: "Manual", sent_on: Array.new)
        redirect_to users_path
      else
        render action: 'new'
      end
    end

    def testmail
    end

    def sendtest
      emails = params[:email][:email_id].split(",")
      Light::Enqueue.perform_async(emails)

      redirect_to newsletters_path
    end

    def unsubscribe
      unless(@user.sidekiq_status == 'Subscribed')
        @message = 'You have already unsubscribed!!'
      else
        @user.update(sidekiq_status: 'Unsubscribed')
        @message = 'Unsubscribed successfully!!'
      end
    end

    def subscribe
      @user.update(sidekiq_status: 'Subscribed', subscribed_at: DateTime.now, remote_ip: request.remote_ip, user_agent: request.env['HTTP_USER_AGENT'])
    end

    def sendmailer
      Light::UserWorker.perform_async
      redirect_to newsletters_path
    end

    def edit
      @user = Light::User.find(params[:id])
    end

    def update
      @user = Light::User.find(params[:id])
      if @user.update_attributes(users_params)
        redirect_to users_path
      else
        render action: 'edit'
      end
    end

    def destroy
      @user = Light::User.find(params[:id])
      @user.destroy
      redirect_to users_path
    end

    def remove
      if @user.present?
        @user.destroy
        @message = "We have removed you from our database!"
      else
        @message = "No user with this token exists!"
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
        if @user.sidekiq_status.eql?('Unsubscribed')
          Light::UserMailer.auto_opt_in(@user.email_id, @user.slug, @user.token).deliver
          #send email
        end
      else
        u_name = params[:username].blank? ? params[:email] : params[:username]
        @user=Light::User.new(username: u_name, 
                              email_id: params[:email], 
                              sidekiq_status: 'web subscription request')
        if @user.save
          Light::UserMailer.auto_opt_in(@user.email_id, @user.slug, @user.token).deliver
        end
      end
      respond_to do |format| 
        format.json { head :no_content }
        format.html {redirect_to main_app.users_thank_you_path}
      end
    end

    def thank_you

    end
    
    private
    def users_params
      params.require(:user).permit(:id, :email_id, :sidekiq_status, :joined_on, :source, :username)
    end

    def user_with_token
      @user = Light::User.where(token: params[:token]).first
    end
  end
end
