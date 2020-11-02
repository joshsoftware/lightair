require_dependency "light/application_controller"

module Light
  class NewslettersController < ApplicationController

    before_filter :load_newsletter, only: [:send_newsletter, :send_test_mail, :test_mail]

    def index
      type = params[:type].present? ? params[:type] : "Monthly Newsletter" 
      @newsletters = Newsletter.where(newsletter_type: type).order_by([:sent_on, :desc])
    end

    def show
      @newsletter = Newsletter.find(params[:id])
    end

    def new 
      @newsletter = Newsletter.new
    end

    def create 
      @newsletter = Newsletter.new(newsletters_params)
      if @newsletter.save
        @newsletter.update(sent_on: Date.today)
        Light::CreateImageWorker.perform_async(@newsletter.id.to_s)
        redirect_to newsletters_path
      else
        render action: 'new'
      end
    end

    def edit
      @newsletter = Newsletter.find(params[:id])
    end

    def update
      @newsletter = Newsletter.find(params[:id])
      if @newsletter.update_attributes(newsletters_params)
        Light::CreateImageWorker.perform_async(@newsletter.id.to_s)
        redirect_to newsletters_path
      else
        render action: 'edit'
      end
    end

    def destroy
      @newsletter = Newsletter.find(params[:id])
      @newsletter.destroy
      redirect_to newsletters_path
    end

    def web_version
      @newsletter = Newsletter.find(params[:id])
      render layout: false
    end

    def send_newsletter
      type = @newsletter.newsletter_type

      case type
      when "Opt-In Letter"
        Light::OptInWorker.perform_async(@newsletter.id.to_s)
        redirect_to newsletters_path
      when "Opt-Out Letter"
        Light::OptOutWorker.perform_async(@newsletter.id.to_s)
        redirect_to newsletters_path
      else
        Light::UserWorker.perform_async(@newsletter.id.to_s)
        redirect_to newsletters_path
      end

    end

    def send_test_mail
      type = @newsletter.newsletter_type
      emails = params[:email][:email_id].split(",")
      Light::UserMailer.welcome_message(emails, @newsletter, 'test_user_dummy_id').deliver if @newsletter
      redirect_to newsletter_path(@newsletter)
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
