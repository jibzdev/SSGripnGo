module Admin
  class ChangelogController < BaseController
    def index
      @entries = Activity.where("description LIKE ?", 'Changelog:%').order(created_at: :desc).limit(50)
    end

    def create
      message = params[:changelog].to_s.strip
      if message.blank?
        redirect_to admin_changelog_path, alert: 'Please provide a changelog entry.' and return
      end

      Activity.create!(user: current_user, description: "Changelog: #{message}")
      redirect_to admin_changelog_path, notice: 'Changelog entry recorded.'
    end
  end
end

