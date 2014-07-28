class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    if params[:user]

    else
      @user = User.new
    end
  end

  def create
    @user = User.new(users_params)
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
    Enqueue.perform_async(emails)

    redirect_to newsletters_path
  end
  
  def subscribe
    @user = User.find(params[:id])
    @user.update(is_subscribed: 'false')
  end
  
  def sendmailer

    #@users = User.where(is_subscribed: "true")
    HardWorker.perform_async(true)

    redirect_to newsletters_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(users_params)
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
  
  private
  def users_params
    params.require(:user).permit(:id, :email_id, :is_subscribed, :joined_on, :source, :username)
  end

end
