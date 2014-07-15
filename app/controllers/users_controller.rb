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
    # @news = Newsletter.last
    
    #respond_to do |format|
    if @user.save
      redirect_to users_path  
        # UserMailer.welcome_message(@user,@news.content).deliver
        # format.html { redirect_to(@user, notice: 'User was successfully created.')}
        # format.json { render json: @user, status: :created, locaton: @user}
    else
      render action: 'new'
        # format.html {render action: 'new'}
        # format.json {render json: @user.errors, status: :unprocessable_entity }
    end
      #end
  end

  def subscribe
    @user = User.find(params[:id])
    @user.update(is_subscribed: 'false')
  end
  
  def sendmailer
    #@user = User.where(is_subscribed: 'true')
    #@news = Newsletter.last
    HardWorker.perform_async()
    redirect_to users_path
  end
  
  def users_params
    params.require(:user).permit(:id, :email_id, :is_subscribed, :joined_on, :source, :username)
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
end
