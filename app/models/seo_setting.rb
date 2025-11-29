class SeoSetting < ApplicationRecord
  validates :page_name, presence: true, uniqueness: true
  validates :title, presence: true, length: { maximum: 60 }
  validates :description, presence: true, length: { maximum: 160 }
  validates :keywords, presence: true, length: { maximum: 255 }
  
  # Scopes
  scope :for_page, ->(page_name) { where(page_name: page_name).first }
  
  # Helper methods
  def meta_tags
    {
      title: title,
      description: description,
      keywords: keywords,
      author: author,
      robots: robots,
      og_type: og_type,
      og_url: og_url,
      og_title: og_title || title,
      og_description: og_description || description,
      og_image: og_image,
      twitter_card: twitter_card,
      twitter_url: twitter_url,
      twitter_title: twitter_title || title,
      twitter_description: twitter_description || description,
      twitter_image: twitter_image,
      favicon_url: favicon_url,
      apple_touch_icon_url: apple_touch_icon_url,
      canonical_url: canonical_url
    }
  end
  
  def self.default_pages
    %w[landing login register terms_of_service privacy_policy]
  end
  
  def self.initialize_defaults
    default_pages.each do |page|
      unless exists?(page_name: page)
        create!(
          page_name: page,
          title: default_title_for(page),
          description: default_description_for(page),
          keywords: default_keywords_for(page),
          author: 'SSGrip',
          robots: 'index, follow',
          og_type: 'website',
          og_url: "https://ssgrip.store/#{page == 'landing' ? '' : page}",
          og_title: default_title_for(page),
          og_description: default_description_for(page),
          og_image: 'https://ssgrip.store/assets/images/logo4.png',
          twitter_card: 'summary_large_image',
          twitter_url: "https://ssgrip.store/#{page == 'landing' ? '' : page}",
          twitter_title: default_title_for(page),
          twitter_description: default_description_for(page),
          twitter_image: 'https://ssgrip.store/assets/images/logo4.png',
          favicon_url: 'https://ssgrip.store/assets/images/logo3.png',
          apple_touch_icon_url: 'https://ssgrip.store/assets/images/logo3.png',
          canonical_url: "https://ssgrip.store/#{page == 'landing' ? '' : page}"
        )
      end
    end
  end
  
  private
  
  def self.default_title_for(page)
    case page
    when 'landing'
      'SSGrip - Performance store & lifestyle garage'
    when 'login'
      'Login - SSGrip'
    when 'register'
      'Register - SSGrip'
    when 'terms_of_service'
      'Terms of Service - SSGrip'
    when 'privacy_policy'
      'Privacy Policy - SSGrip'
    else
      'SSGrip'
    end
  end
  
  def self.default_description_for(page)
    case page
    when 'landing'
      'Build faster with SSGrip—performance parts, aero upgrades, and track lifestyle essentials shipped from the UK.'
    when 'login'
      'Access your SSGrip account to manage orders, deliveries, and store preferences.'
    when 'register'
      'Create an SSGrip account to track orders, save builds, and unlock early drops.'
    when 'terms_of_service'
      'Terms and conditions for shopping with SSGrip. Read our service agreement and store policies.'
    when 'privacy_policy'
      'Privacy policy for SSGrip. Learn how we protect and handle your personal information and data.'
    else
      'SSGrip - Performance store and lifestyle garage'
    end
  end
  
  def self.default_keywords_for(page)
    case page
    when 'landing'
      'performance parts, aero kits, car merch, motorsport lifestyle, SSGrip store'
    when 'login'
      'login, account access, SSGrip, performance store'
    when 'register'
      'register, sign up, SSGrip, performance store'
    when 'terms_of_service'
      'terms, conditions, service agreement, SSGrip, policies'
    when 'privacy_policy'
      'privacy, data protection, personal information, SSGrip'
    else
      'SSGrip, performance store, automotive lifestyle'
    end
  end
end
