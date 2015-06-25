require_dependency "light/application_controller"
module Light
  class UsersController < ApplicationController
    respond_to :js, :json, :html

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
        @user.update(is_subscribed: true, joined_on: Date.today, source: "Manual",sent_on: Array.new)
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
      @user = Light::User.find(params[:id])
      unless(@user.is_subscribed)
        @message = 'You have already unsubscribed!!'
      else
        @user.update(is_subscribed: 'false')
        @message = 'Unsubscribed successfully!!'
      end
    end

    def subscribe
      @user = Light::User.find(params[:id])
      @user.update(is_subscribed: 'true')
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

    def import
      if request.post?
        message = Light::User.import(params[:file]).first
        flash[message.first] = message.last
      end
      render action: :import
    end

    private
    def users_params
      params.require(:user).permit(:id, :email_id, :is_subscribed, :joined_on, :source, :username)
    end
  end
end
