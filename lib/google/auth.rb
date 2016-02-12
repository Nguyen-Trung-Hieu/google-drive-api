module Google
  SCOPES = [
    "https://www.googleapis.com/auth/drive",
    "email",
    "profile"
  ]
  REDIRECT_URI = "http://localhost:3000/google_authenticates"
  CLIENT_ID = ENV["CLIENT_ID"]
  CLIENT_SECRET = ENV["CLIENT_SECRET"]

  class Auth
    class << self
      def get_authorization_url
        client = Google::APIClient.new
        client.authorization.client_id = CLIENT_ID
        client.authorization.redirect_uri = REDIRECT_URI
        client.authorization.scope = SCOPES

        return client.authorization.authorization_uri(
          approval_prompt: :force,
          access_type: :offline
        ).to_s
      end

      def exchange_code authorization_code
        client = Google::APIClient.new
        client.authorization.client_id = CLIENT_ID
        client.authorization.client_secret = CLIENT_SECRET
        client.authorization.code = authorization_code
        client.authorization.redirect_uri = REDIRECT_URI

        begin
          client.authorization.fetch_access_token!
          return client.authorization
        rescue Signet::AuthorizationError
          raise CodeExchangeError.new nil
        end
      end

      def build_client credentials
        client = Google::APIClient.new
        client.authorization = credentials
        client
      end

      def build_drive client
        client.discovered_api("drive", "v2")
      end

      def build_oauth
        client.discovered_api("oauth2", "v2")
      end
    end
  end

  class GetCredentialsError < StandardError
    def initialize authorization_url
      @authorization_url = authorization_url
    end

    def authorization_url=(authorization_url)
      @authorization_url = authorization_url
    end

    def authorization_url
      @authorization_url
    end
  end

  class CodeExchangeError < GetCredentialsError
  end

  class NoRefreshTokenError < GetCredentialsError
  end
end