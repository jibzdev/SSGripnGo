module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: [:update, :destroy, :refund]

    def index
      scope = Payment.includes(:user, :payment_ip_logs).order(created_at: :desc)

      if params[:query].present?
        query = "%#{params[:query].downcase}%"
        scope = scope.left_outer_joins(:user).where(
          <<~SQL.squish,
            CAST(payments.id AS TEXT) LIKE :query
            OR LOWER(COALESCE(payments.reference_code, '')) LIKE :query
            OR LOWER(COALESCE(users.email, '')) LIKE :query
            OR LOWER(COALESCE(users.username, '')) LIKE :query
          SQL
          query: query
        )
      end

      @payments = scope
      @payments_payload = @payments.map { |payment| serialize_payment(payment) }
    end

    def update
      status = payment_params[:status]
      unless Payment.statuses.key?(status)
        return render json: { error: 'Invalid status' }, status: :unprocessable_entity
      end

      @payment.update(status: status)
      respond_to do |format|
        format.html { redirect_to admin_payments_path, notice: 'Payment updated.' }
        format.json { head :ok }
      end
    end

    def destroy
      @payment.destroy
      respond_to do |format|
        format.html { redirect_to admin_payments_path, notice: 'Payment deleted.' }
        format.json { head :no_content }
      end
    end

    def refund
      @payment.update(status: :refunded)
      respond_to do |format|
        format.html { redirect_to admin_payments_path, notice: 'Payment marked as refunded.' }
        format.json { head :ok }
      end
    end

    private

    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:status)
    end

    def serialize_payment(payment)
      user = payment.user
      user_payload =
        if user
          { id: user.id, username: user.username, email: user.email }
        else
          { id: nil, username: 'Guest', email: 'guest@example.com' }
        end

      {
        id: payment.id,
        amount: payment.amount,
        status: payment.status,
        payment_type: payment.payment_type,
        currency: payment.currency,
        created_at: payment.created_at,
        stripe_charge_id: payment.stripe_charge_id,
        stripe_session_id: payment.stripe_session_id,
        reference_code: payment.reference_code,
        user: user_payload,
        payment_ip_logs: payment.payment_ip_logs.order(created_at: :desc).map do |log|
          {
            ip_address: log.ip_address,
            created_at: log.created_at
          }
        end
      }
    end
  end
end

