class AddressLookupsController < ApplicationController
  before_action :require_login

  def show
    postcode = params[:postcode].to_s.strip.upcase
    if postcode.blank?
      render json: { error: 'Please enter a postcode.' }, status: :unprocessable_entity and return
    end

    addresses = PostcodeLookupService.new(postcode).lookup

    if addresses.present?
      render json: { addresses: addresses }
    else
      render json: { addresses: [] }, status: :not_found
    end
  rescue StandardError => e
    Rails.logger.error("Postcode lookup failed: #{e.message}")
    render json: { error: 'Unable to fetch address suggestions right now.' }, status: :bad_gateway
  end
end

