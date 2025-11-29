class ProductsController < ApplicationController
  layout 'application'

  def index
    @categories = Category.active
    @selected_category = @categories.find { |c| c.slug == params[:category] }
    @query = params[:q].to_s.strip
    @sort = params[:sort].presence_in(%w[newest price_low price_high popular]) || 'newest'

    @products = Product.published.includes(:category)
    @products = @products.where(category_id: @selected_category.id) if @selected_category

    if @query.present?
      sanitized = "%#{@query.downcase}%"
      @products = @products.where('LOWER(name) LIKE ? OR LOWER(short_description) LIKE ?', sanitized, sanitized)
    end

    @products = apply_sort(@products)
    @products = @products.page(params[:page]).per(12)
  end

  def show
    @product = Product.published.includes(:category).find_by!(slug: params[:id])
    @related_products = Product.published
                                .where(category_id: @product.category_id)
                                .where.not(id: @product.id)
                                .limit(4)
  end

  private

  def apply_sort(scope)
    case @sort
    when 'price_low'
      scope.order(price: :asc)
    when 'price_high'
      scope.order(price: :desc)
    when 'popular'
      scope.order(featured: :desc, stock_quantity: :desc)
    else
      scope.order(published_at: :desc)
    end
  end
end

