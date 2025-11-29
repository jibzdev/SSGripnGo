class GoogleSignInService
    GOOGLE_AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
    GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token'
    GOOGLE_USER_INFO_URL = 'https://www.googleapis.com/oauth2/v3/userinfo'
  
    def initialize(redirect_uri)
      @client_id = ENV['GOOGLE_CLIENT_ID'] || Rails.application.credentials.google_client_id
      @client_secret = ENV['GOOGLE_CLIENT_SECRET'] || Rails.application.credentials.google_client_secret
      @redirect_uri = redirect_uri
    end

    def authorization_url
      query_params = {
        client_id: @client_id,
        redirect_uri: @redirect_uri,
        response_type: 'code',
        scope: 'email profile',
        access_type: 'offline',
        include_granted_scopes: 'true',
        prompt: 'consent'
      }
      puts "Authorization URL: #{GOOGLE_AUTH_URL}?#{URI.encode_www_form(query_params)}"
      "#{GOOGLE_AUTH_URL}?#{URI.encode_www_form(query_params)}"
    end

    def fetch_tokens(code)
      uri = URI.parse(GOOGLE_TOKEN_URL)
      response = Net::HTTP.post_form(uri, {
        code: code,
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: @redirect_uri,
        grant_type: 'authorization_code'
      })
      
      if response.code == '200'
        JSON.parse(response.body)
      else
        Rails.logger.error "Google OAuth token request failed: #{response.code} - #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching Google OAuth tokens: #{e.message}"
      nil
    end

    def fetch_user_info(access_token)
      uri = URI.parse(GOOGLE_USER_INFO_URL)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      
      if response.code == '200'
        JSON.parse(response.body)
      else
        Rails.logger.error "Google user info request failed: #{response.code} - #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching Google user info: #{e.message}"
      nil
    end
  end
