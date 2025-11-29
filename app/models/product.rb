class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :basket_items, dependent: :destroy
  has_many :order_items, dependent: :nullify

  enum status: {
    draft: 'draft',
    scheduled: 'scheduled',
    published: 'published',
    retired: 'retired'
  }

  validates :name, presence: true, length: { maximum: 160 }
  validates :slug, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_save :clamp_stock_values
  before_save :normalize_images

  scope :available, -> { published.where('stock_quantity > 0') }
  scope :featured, -> { published.where(featured: true) }
  scope :recent, -> { published.order(published_at: :desc).limit(12) }

  def to_param
    slug
  end

  def display_price
    ApplicationController.helpers.number_to_currency(price, unit: currency_symbol)
  end

  def compare_price?
    compare_at_price.present? && compare_at_price > price
  end

  def currency_symbol
    case currency
    when 'USD' then '$'
    when 'EUR' then '€'
    else '£'
    end
  end

  def in_stock?
    stock_quantity.positive?
  end

  def low_stock?
    in_stock? && stock_quantity <= low_stock_threshold
  end

  def max_purchaseable_quantity
    return stock_quantity unless max_per_order.present?
    [stock_quantity, max_per_order].min
  end

  def delivery_window
    shipping_lead_time.presence || 'Ships in 1-3 business days'
  end

  def snapshot
    {
      id: id,
      name: name,
      slug: slug,
      sku: sku,
      hero_image: primary_image,
      gallery_images: secondary_images,
      price: price,
      currency: currency,
      delivery_window: delivery_window
    }
  end

  def all_images
    primary = hero_image.presence
    rest = Array.wrap(gallery_images).map(&:presence).compact
    primary ? [primary, *rest] : rest
  end

  def primary_image
    all_images.first
  end

  def secondary_images
    all_images.drop(1)
  end

  def hover_image
    secondary_images.first
  end

  private

  def generate_slug
    base_slug = name.to_s.parameterize
    candidate = base_slug
    counter = 2

    while Product.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end

  def clamp_stock_values
    self.stock_quantity = [stock_quantity || 0, 0].max
    self.low_stock_threshold = [low_stock_threshold || 0, 0].max
  end

  def normalize_images
    self.hero_image = hero_image.presence
    self.gallery_images = Array.wrap(gallery_images).map(&:presence).compact
  end
end

