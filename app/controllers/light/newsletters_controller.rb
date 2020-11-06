require_dependency "light/application_controller"

module Light
  class NewslettersController < ApplicationController

    before_filter :load_newsletter, only: [:send_newsletter, :send_test_mail, :test_mail,
                                           :show, :edit, :update, :destroy, :web_version]

    def index
      type = params[:type].present? ? params[:type] : 'Monthly Newsletter'
      @newsletters = Newsletter.where(newsletter_type: type).order_by([:sent_on, :desc])
    end

    def show
    end

    def new 
      @newsletter = Newsletter.new
    end

    def create 
      @newsletter = Newsletter.new(newsletters_params)
      if @newsletter.save
        @newsletter.update(sent_on: Date.today)
        Light::CreateImageWorker.perform_async(@newsletter.id.to_s)
        flash[:success] = 'Newsletter created successfully'
        redirect_to newsletters_path(type: @newsletter.newsletter_type)
      else
        flash[:error] = 'Error while creating newsletter'
        render action: 'new'
      end
    end

    def edit
    end

    def update
      if @newsletter.update_attributes(newsletters_params)
        Light::CreateImageWorker.perform_async(@newsletter.id.to_s)
        flash[:success] = 'Newsletter updated successfully'
        redirect_to newsletters_path(type: @newsletter.newsletter_type)
      else
        flash[:error] = 'Error while updating newsletter'
        render action: 'edit'
      end
    end

    def destroy
      if @newsletter.destroy
        flash[:success] = 'Newsletter deleted successfully'
      else
        flash[:error] = 'Error while deleting newsletter'
      end
      redirect_to newsletters_path(type: @newsletter.newsletter_type)
    end

    def web_version
      render layout: false
    end

    def send_newsletter
      if @newsletter
        type = @newsletter.newsletter_type

        case type
        when 'Opt-In Letter'
          Light::OptInWorker.perform_async(@newsletter.id.to_s)
          flash[:notice] = 'Sent Opt-In newsletter successfully'
        when 'Opt-Out Letter'
          Light::OptOutWorker.perform_async(@newsletter.id.to_s)
          flash[:notice] = 'Sent Opt-Out newsletter successfully'
        when 'Monthly Newsletter'
          Light::UserWorker.perform_async(@newsletter.id.to_s)
          flash[:notice] = 'Sent Monthly newsletter successfully'
        else
          flash[:error] = 'Invalid newsletter type'
        end
        redirect_to newsletters_path(type: type)
      else
        flash[:error] = 'Newsletter not found.'
        redirect_to newsletters_path
      end
    end

    def send_test_mail
      emails = params[:email][:email_id].split(",")
      unless emails.empty?
        if @newsletter
          Light::UserMailer.welcome_message(emails, @newsletter, 'test_user_dummy_id').deliver
          flash[:notice] = 'You will receive newsletter on the given email ids shortly.'
          redirect_to newsletters_path(type: @newsletter.newsletter_type)
        else
          flash[:error] = 'Newsletter not found.'
          redirect_to newsletter_path
        end
      else
        flash[:error] = 'Atleast one email ID is expected.'
        render 'test_mail'
      end
    end

    def test_mail
    end
    
    private

    def newsletters_params
      params.require(:newsletter).permit(:id, :subject, :content, :sent_on, :users_count, :newsletter_type)
    end

    def load_newsletter
      @newsletter = Newsletter.find(params[:id])
    end
  end
end
