class ReviewsController < ApplicationController
  before_action :require_login, except: :index
  before_action :set_review, only: [:edit, :update, :destroy]

  def index
    @reviews = Review.published.recent.includes(:user).with_attached_photo
    @review = if user_signed_in?
                current_user.review || current_user.build_review
              else
                Review.new
              end
  end

  def create
    return redirect_to reviews_path, alert: 'You have already submitted a review.' if current_user.review.present?

    @review = current_user.build_review(review_params)
    if @review.save
      redirect_to reviews_path, notice: 'Thanks for sharing your experience!'
    else
      @reviews = Review.published.recent.includes(:user).with_attached_photo
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to reviews_path, notice: 'Your review has been updated.'
    else
      @reviews = Review.published.recent.includes(:user).with_attached_photo
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to reviews_path, notice: 'Your review has been removed.'
  end

  private

  def set_review
    @review = current_user.review
    redirect_to reviews_path, alert: 'Review not found.' unless @review
  end

  def review_params
    params.require(:review).permit(:rating, :title, :body, :photo)
  end
end

