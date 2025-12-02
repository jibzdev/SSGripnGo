class UserMailer < ApplicationMailer

  def order_confirmation(order)
    @order = order
    @user = order.user
    @general_setting = GeneralSetting.first_or_initialize
    mail(
      to: @order.email || @user&.email,
      subject: "Order #{@order.order_number} confirmed"
    )
  end

  def order_status_update(order)
    @order = order
    @general_setting = GeneralSetting.first_or_initialize
    mail(
      to: @order.email,
      subject: "Order #{@order.order_number} status updated"
    )
  end

  def welcome_email(user)
    @user = user
    @general_setting = GeneralSetting.first_or_initialize
    
    mail(
      to: @user.email,
      subject: "Welcome to RK Customs!"
    )
  end

  def verification_email(user)
    @user = user
    @general_setting = GeneralSetting.first_or_initialize
    @url = verify_email_url(token: @user.verification_token)
    
    mail(
      to: @user.email,
      subject: "Verify Your Email - RK Customs"
    )
  end

  def forgot_password(user)
    @user = user
    @general_setting = GeneralSetting.first_or_initialize
    
    mail(
      to: @user.email,
      subject: "Reset Your Password - RK Customs"
    )
  end
end
