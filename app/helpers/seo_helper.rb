module SeoHelper
  def seo_meta_tags(page_name = nil)
    seo_setting = page_name ? SeoSetting.for_page(page_name) : nil
    # Be defensive: if a relation is returned or nil, normalize
    seo_setting = seo_setting.first if seo_setting.is_a?(ActiveRecord::Relation)
    return generate_meta_tags(seo_setting.meta_tags) if seo_setting&.respond_to?(:meta_tags)
    generate_default_meta_tags
  end

  def generate_meta_tags(meta_tags)
    tags = []
    
    # Primary Meta Tags
    tags << tag(:meta, charset: 'UTF-8')
    tags << tag(:meta, name: 'viewport', content: 'width=device-width, initial-scale=1.0')
    tags << tag(:meta, name: 'title', content: meta_tags[:title])
    tags << tag(:meta, name: 'description', content: meta_tags[:description])
    tags << tag(:meta, name: 'keywords', content: meta_tags[:keywords])
    tags << tag(:meta, name: 'author', content: meta_tags[:author])
    tags << tag(:meta, name: 'robots', content: meta_tags[:robots])
    
    # Open Graph / Facebook
    tags << tag(:meta, property: 'og:type', content: meta_tags[:og_type])
    tags << tag(:meta, property: 'og:url', content: meta_tags[:og_url])
    tags << tag(:meta, property: 'og:title', content: meta_tags[:og_title])
    tags << tag(:meta, property: 'og:description', content: meta_tags[:og_description])
    tags << tag(:meta, property: 'og:image', content: meta_tags[:og_image])
    
    # Twitter
    tags << tag(:meta, property: 'twitter:card', content: meta_tags[:twitter_card])
    tags << tag(:meta, property: 'twitter:url', content: meta_tags[:twitter_url])
    tags << tag(:meta, property: 'twitter:title', content: meta_tags[:twitter_title])
    tags << tag(:meta, property: 'twitter:description', content: meta_tags[:twitter_description])
    tags << tag(:meta, property: 'twitter:image', content: meta_tags[:twitter_image])
    
    # Favicon
    tags << tag(:link, rel: 'icon', type: 'image/png', href: meta_tags[:favicon_url]) if meta_tags[:favicon_url].present?
    tags << tag(:link, rel: 'apple-touch-icon', href: meta_tags[:apple_touch_icon_url]) if meta_tags[:apple_touch_icon_url].present?
    
    # Canonical URL
    tags << tag(:link, rel: 'canonical', href: meta_tags[:canonical_url]) if meta_tags[:canonical_url].present?
    
    # Structured Data
    tags << structured_data_tag(meta_tags[:structured_data]) if meta_tags[:structured_data].present?
    
    safe_join(tags.compact)
  end

  def generate_default_meta_tags
    tags = []
    
    tags << tag(:meta, charset: 'UTF-8')
    tags << tag(:meta, name: 'viewport', content: 'width=device-width, initial-scale=1.0')
    tags << tag(:meta, name: 'title', content: 'RK Customs - Premium Vehicle Services')
    tags << tag(:meta, name: 'description', content: 'Transform your vehicle with premium window tinting, paint protection, custom wraps, and detailing services. Professional automotive aesthetics in Portsmouth.')
    tags << tag(:meta, name: 'keywords', content: 'vehicle tinting, window tinting, paint protection, car wrapping, vehicle detailing, automotive services, Portsmouth')
    tags << tag(:meta, name: 'author', content: 'RK Customs')
    tags << tag(:meta, name: 'robots', content: 'index, follow')
    
    # Open Graph
    tags << tag(:meta, property: 'og:type', content: 'website')
    tags << tag(:meta, property: 'og:title', content: 'RK Customs - Premium Vehicle Services')
    tags << tag(:meta, property: 'og:description', content: 'Transform your vehicle with premium window tinting, paint protection, custom wraps, and detailing services.')
    tags << tag(:meta, property: 'og:image', content: asset_url('images/logo4.png'))
    
    # Twitter
    tags << tag(:meta, property: 'twitter:card', content: 'summary_large_image')
    tags << tag(:meta, property: 'twitter:title', content: 'RK Customs - Premium Vehicle Services')
    tags << tag(:meta, property: 'twitter:description', content: 'Transform your vehicle with premium window tinting, paint protection, custom wraps, and detailing services.')
    tags << tag(:meta, property: 'twitter:image', content: asset_url('images/logo4.png'))
    
    # Favicon
    tags << tag(:link, rel: 'icon', type: 'image/png', href: asset_url('images/logo3.png'))
    tags << tag(:link, rel: 'apple-touch-icon', href: asset_url('images/logo3.png'))
    
    safe_join(tags)
  end

  def structured_data_tag(json_ld)
    return unless json_ld.present?
    
    begin
      # Validate JSON
      JSON.parse(json_ld)
      tag(:script, type: 'application/ld+json') { json_ld.html_safe }
    rescue JSON::ParserError
      Rails.logger.warn "Invalid JSON-LD structured data: #{json_ld}"
      nil
    end
  end

  def seo_title(page_name = nil)
    seo_setting = page_name ? SeoSetting.for_page(page_name) : nil
    seo_setting&.title || 'RK Customs - Premium Vehicle Services'
  end

  def seo_description(page_name = nil)
    seo_setting = page_name ? SeoSetting.for_page(page_name) : nil
    seo_setting&.description || 'Transform your vehicle with premium window tinting, paint protection, custom wraps, and detailing services. Professional automotive aesthetics in Portsmouth.'
  end
end
