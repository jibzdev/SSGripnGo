class StripeSetting < ApplicationRecord
  validates :publishable_key, presence: true, if: :stripe_enabled?
  validates :secret_key, presence: true, if: :stripe_enabled?
  
  private
  
  def stripe_enabled?
    publishable_key.present? || secret_key.present?
  end
end 