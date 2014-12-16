module Light
  class Newsletter
    include Mongoid::Document
    include Mongoid::Slug
    include Mongoid::Paperclip

    field :subject,     type: String
    field :content,     type: String 
    field :sent_on,     type: Date
    field :users_count,  type: Integer, default: 0

    validates :content, :subject, presence: true
    validates :subject, uniqueness: true

    has_mongoid_attached_file :photo,:styles => {:original => ['1920x1680>', :png],:small  => ['220x180!', :png]}
    validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "application/pdf"]

    has_many :users
    slug :subject

    def get_image
      photo.present? ? photo.url(:small) : "/images/newsletter.jpg"
    end
  end
end
