class CategoriesController < ApplicationController
  layout 'application'

  def show
    @category = Category.active.find_by!(slug: params[:id])
    @categories = Category.active
    @selected_category = @category
    @products = @category.products.published.order(published_at: :desc).page(params[:page]).per(12)
    render 'products/index'
  end
end

