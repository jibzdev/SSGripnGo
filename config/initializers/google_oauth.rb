# Google OAuth Configuration
# This file contains the configuration for Google OAuth integration

# You can set these values in your environment variables or Rails credentials
# Environment variables take precedence over credentials

Rails.application.configure do
  # Google OAuth credentials
  config.google_client_id = ENV['GOOGLE_CLIENT_ID'] || Rails.application.credentials.google_client_id
  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET'] || Rails.application.credentials.google_client_secret
  
  # Google OAuth URLs
  config.google_auth_url = 'https://accounts.google.com/o/oauth2/v2/auth'
  config.google_token_url = 'https://oauth2.googleapis.com/token'
  config.google_user_info_url = 'https://www.googleapis.com/oauth2/v3/userinfo'
  
  # OAuth scopes
  config.google_oauth_scopes = 'email profile'
end

# Validation
if Rails.env.production?
  unless Rails.application.config.google_client_id.present? && Rails.application.config.google_client_secret.present?
    Rails.logger.warn "Google OAuth credentials not configured. Google sign-in will not work."
  end
end
