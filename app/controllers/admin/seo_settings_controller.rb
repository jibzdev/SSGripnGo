module Admin
  class SeoSettingsController < BaseController
    before_action :set_seo_setting, only: [:show, :edit, :update, :destroy]

    def index
      @seo_settings = SeoSetting.order(created_at: :desc)
    end

    def show; end

    def new
      @seo_setting = SeoSetting.new
    end

    def create
      @seo_setting = SeoSetting.new(seo_setting_params)
      if @seo_setting.save
        redirect_to admin_seo_settings_path, notice: 'SEO setting created.'
      else
        flash.now[:alert] = @seo_setting.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @seo_setting.update(seo_setting_params)
        redirect_to admin_seo_settings_path, notice: 'SEO setting updated.'
      else
        flash.now[:alert] = @seo_setting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @seo_setting.destroy
      redirect_to admin_seo_settings_path, notice: 'SEO setting deleted.'
    end

    def initialize_defaults
      SeoSetting.initialize_defaults
      redirect_to admin_seo_settings_path, notice: 'Default SEO settings initialized.'
    end

    private

    def set_seo_setting
      @seo_setting = SeoSetting.find(params[:id])
    end

    def seo_setting_params
      params.require(:seo_setting).permit(
        :page_name,
        :title,
        :description,
        :keywords,
        :author,
        :robots,
        :og_type,
        :og_url,
        :og_title,
        :og_description,
        :og_image,
        :twitter_card,
        :twitter_url,
        :twitter_title,
        :twitter_description,
        :twitter_image,
        :favicon_url,
        :apple_touch_icon_url,
        :canonical_url,
        :image_url,
        :structured_data
      )
    end
  end
end

