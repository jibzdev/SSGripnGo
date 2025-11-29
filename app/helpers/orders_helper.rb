module OrdersHelper
  def order_progress_step(order)
    # Returns the current step number (1-5) based on order status and payment status
    # Step 5: Order Fulfilled
    return 5 if order.status == 'fulfilled'
    
    # Step 4: Confirmed & Preparing (confirmed status or processing)
    return 4 if order.status == 'confirmed' || order.status == 'processing'
    
    # Step 3: Processing order (payment is paid but order is still pending)
    return 3 if order.payment_status == 'paid' && order.status == 'pending'
    
    # Step 2: Awaiting Payment
    return 2 if order.payment_status == 'awaiting_payment'
    
    # Step 1: Awaiting Confirmation (default state - pending/unpaid)
    1
  end

  def order_progress_stages
    [
      { step: 1, label: 'Awaiting Confirmation', icon: 'clock' },
      { step: 2, label: 'Awaiting Payment', icon: 'credit-card' },
      { step: 3, label: 'Processing Order', icon: 'cog' },
      { step: 4, label: 'Confirmed & Preparing', icon: 'package' },
      { step: 5, label: 'Order Fulfilled', icon: 'check' }
    ]
  end
end

