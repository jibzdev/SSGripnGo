module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :edit, :update, :destroy, :update_status, :update_payment_status]

    def index
      @orders = Order.includes(:user).order(created_at: :desc)
    end

    def show; end

    def destroy
      @order.destroy
      redirect_to admin_orders_path, notice: 'Order deleted.'
    end

    def update_status
      if params[:status].present? && Order.statuses.key?(params[:status])
        if @order.update(status: params[:status])
          send_status_email(@order)
          redirect_to admin_order_path(@order), notice: 'Order status updated.'
        else
          redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
        end
      else
        redirect_to admin_order_path(@order), alert: 'Invalid status.'
      end
    end

    def update_payment_status
      payment_status = params[:payment_status]
      unless payment_status.present? && Order.payment_statuses.key?(payment_status)
        return redirect_to admin_order_path(@order), alert: 'Invalid payment status.'
      end

      @order.payment_status = payment_status
      @order.metadata = (@order.metadata || {}).merge('reference_code' => params[:reference_code].to_s).compact

      if @order.save
        redirect_to admin_order_path(@order), notice: 'Payment status updated.'
      else
        redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    end

    private

    def set_order
      identifier = params[:id] || params[:order_id]
      @order = Order.includes(:order_items, :user).find_by!(order_number: identifier)
    end

    def send_status_email(order)
      return unless defined?(UserMailer) && !Rails.env.test?

      UserMailer.order_status_update(order).deliver_later
    rescue => e
      Rails.logger.error("Failed to send status update for #{order.order_number}: #{e.message}")
    end
  end
end

