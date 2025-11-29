class Review < ApplicationRecord
  belongs_to :user

  RATINGS = 1..5

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  validates :title, :body, presence: true
  validates :body, length: { minimum: 20 }
  validates :rating, presence: true, inclusion: { in: RATINGS }
  validates :user_id, uniqueness: true

  def author_name
    user&.display_name || 'Anonymous'
  end
end

