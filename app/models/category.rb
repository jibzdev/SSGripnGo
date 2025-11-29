class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :ordered, -> { order(position: :asc, name: :asc) }
  scope :active, -> { where(active: true).ordered }

  def to_param
    slug
  end

  def hero_image_url
    hero_image.presence || '/assets/images/showcase1.jpg'
  end

  private

  def generate_slug
    base_slug = name.to_s.parameterize
    candidate = base_slug
    counter = 2

    while Category.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end

