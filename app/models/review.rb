class Review < ApplicationRecord
  belongs_to :user
  has_one_attached :photo

  RATINGS = 1..5

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  validates :title, :body, presence: true
  validates :body, length: { minimum: 20 }
  validates :rating, presence: true, inclusion: { in: RATINGS }
  validates :user_id, uniqueness: true
  validate :photo_validation

  def author_name
    user&.display_name || 'Anonymous'
  end

  private

  def photo_validation
    return unless photo.attached?

    if photo.blob.byte_size > 5.megabytes
      errors.add(:photo, 'must be smaller than 5MB')
    end

    acceptable_types = %w[image/jpeg image/png image/webp]
    return if acceptable_types.include?(photo.blob.content_type)

    errors.add(:photo, 'must be a JPG, PNG, or WEBP image')
  end
end

