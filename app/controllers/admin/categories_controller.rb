module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:edit, :update, :destroy, :show]

    def index
      @categories = Category.order(position: :asc, name: :asc)
    end

    def show
      redirect_to edit_admin_category_path(@category)
    end

    def new
      @category = Category.new(active: true, position: Category.maximum(:position).to_i + 1)
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: 'Category created.'
      else
        flash.now[:alert] = @category.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: 'Category updated.'
      else
        flash.now[:alert] = @category.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: 'Category deleted.'
    end

    private

    def set_category
      @category = Category.find_by!(slug: params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name,
        :slug,
        :description,
        :position,
        :active,
        :hero_image,
        :highlight_color
      )
    end
  end
end

