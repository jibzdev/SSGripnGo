module Admin
  class SettingsController < BaseController
    def index
      @general_setting = GeneralSetting.first_or_initialize
    end

    def update
      @general_setting = GeneralSetting.first_or_initialize
      if @general_setting.update(settings_params)
        redirect_to admin_settings_path, notice: 'Settings updated.'
      else
        flash.now[:alert] = @general_setting.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      end
    end

    private

    def settings_params
      params.require(:general_setting).permit(
        :application_name,
        :maintenance_mode,
        :phone_number,
        :contact_email,
        :website_url,
        :bank_account_name,
        :bank_account_number,
        :bank_sort_code,
        :bank_iban,
        :bank_instructions,
        :bank_reference_hint
      )
    end
  end
end

