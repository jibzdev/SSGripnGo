class OrdersController < ApplicationController
  layout 'dashboard', except: :track

  before_action :require_login, except: :track
  before_action :set_order, only: [:show]
  before_action :authorize_order!, only: [:show]
  before_action :load_general_setting, only: [:index, :show, :new, :create, :track]

  def index
    @orders = current_user.orders.recent.includes(:order_items)
    @general_setting = GeneralSetting.first_or_initialize
  end

  def show
    @general_setting = GeneralSetting.first_or_initialize
  end

  def new
    @basket = current_basket
    if @basket.basket_items.empty?
      redirect_to catalog_path, alert: 'Add items to your basket before checking out.'
      return
    end

    if @general_setting.orders_disabled
      redirect_to basket_path, alert: 'Orders are currently disabled. Please contact us via social media to place an order.'
      return
    end

    @order = current_user.orders.build(
      email: current_user.email,
      phone_number: current_user.phone_number
    )
    preload_shipping_address!
  end

  def create
    @basket = current_basket
    if @basket.basket_items.empty?
      redirect_to catalog_path, alert: 'Add items to your basket before checking out.'
      return
    end

    if @general_setting.orders_disabled
      redirect_to basket_path, alert: 'Orders are currently disabled. Please contact us via social media to place an order.'
      return
    end

    Order.transaction do
      @order = current_user.orders.create!(
        order_params.merge(
          status: :pending,
          payment_status: :awaiting_payment,
          fulfillment_status: :unfulfilled,
          placed_at: Time.current,
          basket: @basket,
          currency: @basket.currency
        )
      )

      @order.assign_line_items_from_basket!(@basket)
      persist_customer_shipping_profile(@order)
      @basket.empty!
    end

    send_order_confirmation(@order)
    redirect_to order_path(@order.order_number), notice: 'Order placed successfully. You can track it from your dashboard.'
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    @order ||= current_user.orders.build(order_params)
    render :new, status: :unprocessable_entity
  end

  def track
    @lookup_number = params[:order_number].to_s.upcase
    @lookup_email = params[:email].to_s.downcase
    @tracking_order = if @lookup_number.present?
                        Order.find_by(order_number: @lookup_number)
                      end

    if @tracking_order && authorized_for_tracking?(@tracking_order)
      render :track
    elsif @lookup_number.present?
      flash.now[:alert] = 'We could not find an order with that information.'
    end
  end

  private

  def set_order
    @order = Order.find_by!(order_number: params[:order_number] || params[:id])
  end

  def authorize_order!
    return if admin? || (@order.user_id.present? && current_user.id == @order.user_id)
    redirect_to orders_path, alert: 'You do not have access to that order.'
  end

  def order_params
    params.require(:order).permit(
      :email,
      :phone_number,
      :shipping_method,
      :delivery_estimate,
      shipping_address: %i[line1 line2 city region postal_code country],
      billing_address: %i[line1 line2 city region postal_code country]
    )
  end

  def authorized_for_tracking?(order)
    return true if current_user && order.user_id == current_user.id
    return false unless @lookup_email.present?
    order.email.present? && order.email.downcase == @lookup_email
  end

  def load_general_setting
    @general_setting = GeneralSetting.first_or_initialize
  end

  def preload_shipping_address!
    stored_address = current_user.shipping_address_profile
    return if stored_address.blank?

    @order.shipping_address = stored_address.with_indifferent_access
    @order.shipping_address['country'] ||= 'United Kingdom'
  end

  def persist_customer_shipping_profile(order)
    return if order.shipping_address.blank?

    current_user.update_shipping_profile(order.shipping_address)
  end

  def send_order_confirmation(order)
    return unless defined?(UserMailer) && !Rails.env.test?

    UserMailer.order_confirmation(order).deliver_later
  rescue => e
    Rails.logger.error("Failed to send order confirmation for #{order.order_number}: #{e.message}")
  end
end

