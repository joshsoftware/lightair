module Light
  class Newsletter
    include Mongoid::Document
    include Mongoid::Slug
    include Mongoid::Paperclip

    VALID_NEWSLETTER_TYPES = {
      MONTHLY: 'Monthly Newsletter',
      OPT_IN:  'Opt-In Letter',
      OPT_OUT: 'Opt-Out Letter'
    }

    field :subject,     type: String
    field :content,     type: String
    field :sent_on,     type: Date
    field :users_count,  type: Integer, default: 0
    field :newsletter_type,  type: String, default: VALID_NEWSLETTER_TYPES[:MONTHLY]

    validates :content, :subject, :newsletter_type, presence: true
    validates :subject, uniqueness: true
    validates :newsletter_type, inclusion: {in: VALID_NEWSLETTER_TYPES.values}

    scope :opt_in_letters, -> { where(newsletter_type: VALID_NEWSLETTER_TYPES[:OPT_IN]) }
    scope :opt_out_letters, -> { where(newsletter_type: VALID_NEWSLETTER_TYPES[:OPT_OUT]) }
    scope :monthly_letters, -> { where(newsletter_type: VALID_NEWSLETTER_TYPES[:MONTHLY]) }

    has_mongoid_attached_file :photo,styles: {original: ['1920x1680>', :png],small: ['240x200!', :png]}
    validates_attachment_content_type :photo, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'application/pdf']

    slug :subject

    def get_image
      photo.present? ? photo.url(:small) : '/images/newsletter.jpg'
    end

    def opt_in?
      newsletter_type.eql?(VALID_NEWSLETTER_TYPES[:OPT_IN])
    end

    def opt_out?
      newsletter_type.eql?(VALID_NEWSLETTER_TYPES[:OPT_OUT])
    end
  end
end
