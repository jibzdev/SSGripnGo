class BasketsController < ApplicationController
  layout 'application'

  def show
    @basket = current_basket
  end

  def add_item
    product = Product.published.find(params[:product_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    current_basket.add_product(product, quantity: quantity)

    respond_to do |format|
      format.html { redirect_back fallback_location: basket_path, notice: "#{product.name} added to your basket." }
      format.turbo_stream do
        flash.now[:notice] = "#{product.name} added to your basket."
      end
      format.json { render json: { success: true, count: basket_item_count } }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: catalog_path, alert: 'That product is no longer available.'
  rescue StandardError => e
    redirect_back fallback_location: catalog_path, alert: e.message
  end

  def update_item
    item = current_basket.basket_items.find(params[:id])
    quantity = params[:quantity].to_i
    current_basket.update_quantity(item.id, quantity)
    redirect_to basket_path, notice: 'Basket updated.'
  rescue ActiveRecord::RecordNotFound
    redirect_to basket_path, alert: 'Basket item not found.'
  end

  def remove_item
    item = current_basket.basket_items.find(params[:id])
    item.destroy
    current_basket.recalculate_totals!
    redirect_to basket_path, notice: 'Item removed from basket.'
  rescue ActiveRecord::RecordNotFound
    redirect_to basket_path, alert: 'Basket item not found.'
  end

  def destroy
    current_basket.empty!
    redirect_to catalog_path, notice: 'Your basket is now empty.'
  end
end

