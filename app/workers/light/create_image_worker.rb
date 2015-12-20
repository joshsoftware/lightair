module Light
  class CreateImageWorker
    include Sidekiq::Worker
    include Rails.application.routes.url_helpers
    sidekiq_options :queue => :lightair

    def perform(newsletter_id)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      kit = IMGKit.new("#{LIGHT_HOST_URL}/web-version/#{newsletter.slug}",height: 600)
      img = kit.to_img(:jpg)
      file = kit.to_file("#{Rails.root}/public/newsletter/" + newsletter.slug)
      newsletter.update_attributes(photo: open("#{Rails.root}/public/newsletter/" + newsletter.slug))
    end
  end
end
