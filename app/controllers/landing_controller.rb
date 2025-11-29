class LandingController < ApplicationController

  def index
    @general_setting = GeneralSetting.first_or_initialize
    @landing_seo = SeoSetting.for_page('landing')
    @seo_page = 'landing'
    @featured_products = Product.published.featured.limit(4)
    @new_arrivals = Product.published.order(published_at: :desc).limit(6)
    @hero_categories = Category.active.limit(4)
    
    # Real stats for hero section
    @total_orders = Order.where.not(status: :cancelled).count
    @total_products = Product.published.count
    @reviews = Review.published.recent.includes(:user)
  end

  def about
    @general_setting = GeneralSetting.first_or_initialize
    @about_seo = SeoSetting.find_by(page_name: 'about')
  end



  def gallery
    @general_setting = GeneralSetting.first_or_initialize
    @gallery_seo = SeoSetting.find_by(page_name: 'gallery')

    images_root = Rails.root.join('public', 'assets', 'show')
    pattern = File.join(images_root, '**', '*.{jpg,jpeg,png,webp,avif}')
    all_images = Dir.glob(pattern, File::FNM_CASEFOLD)

    # Exclude logos and common icon files
    excluded_regex = /(logo|favicon|icon|brand)/i
    filtered_images = all_images.reject { |path| File.basename(path).match?(excluded_regex) }

    @gallery_images = filtered_images.sort.map do |path|
      path.sub(Rails.root.join('public').to_s, '')
    end
  end

  def contact
    @general_setting = GeneralSetting.first_or_initialize
    @contact_seo = SeoSetting.find_by(page_name: 'contact')
  end

  def terms_of_service
    @general_setting = GeneralSetting.first_or_initialize
    @seo_setting = SeoSetting.for_page('terms_of_service')
  end

  def privacy_policy
    @general_setting = GeneralSetting.first_or_initialize
    @seo_setting = SeoSetting.for_page('privacy_policy')
  end
end
