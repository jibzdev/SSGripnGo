class PaymentsController < ApplicationController
  layout 'dashboard'
  before_action :require_login

  def history
    @payments = current_user.payments.includes(:order).order(created_at: :desc)
  end

  def create
    @order = current_user.orders.find_by(order_number: params[:order_number])
    unless @order
      redirect_to orders_path, alert: 'Order not found.' and return
    end

    payment = current_user.payments.create!(
      order: @order,
      status: :successful,
      amount: @order.total,
      payment_type: 'full_payment',
      payment_method: params[:payment_method] || 'card',
      channel: :storefront,
      paid_at: Time.current
    )

    @order.mark_as_paid!(payment)
    redirect_to order_path(@order), notice: 'Payment recorded successfully.'
  end

  private

  def require_login
    super
  end
end
