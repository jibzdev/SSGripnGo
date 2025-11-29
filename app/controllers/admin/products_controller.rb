module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_featured]
    before_action :load_categories, only: [:new, :create, :edit, :update]

    def index
      @products = Product.includes(:category).order(created_at: :desc)
    end

    def show
      redirect_to edit_admin_product_path(@product)
    end

    def new
      @product = Product.new(status: :draft, currency: 'GBP')
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: 'Product created successfully.'
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Product updated successfully.'
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Product deleted.'
    end

    def toggle_featured
      @product.update(featured: !@product.featured?)
      redirect_to admin_products_path, notice: "Product #{@product.featured? ? 'featured' : 'unfeatured'}."
    end

    def low_stock
      @products = Product.where('stock_quantity <= low_stock_threshold').order(:stock_quantity)
      render :index
    end

    private

    def set_product
      @product = Product.find_by!(slug: params[:id])
    end

    def load_categories
      @categories = Category.order(:name)
    end

    def product_params
      params.require(:product).permit(
        :name,
        :slug,
        :sku,
        :status,
        :featured,
        :category_id,
        :price,
        :compare_at_price,
        :stock_quantity,
        :low_stock_threshold,
        :short_description,
        :description,
        :hero_image,
        :currency,
        :shipping_lead_time,
        :delivery_message,
        :max_per_order,
        gallery_images: [],
        specifications: {}
      )
    end
  end
end

