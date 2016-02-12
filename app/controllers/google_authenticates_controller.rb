class GoogleAuthenticatesController < ApplicationController
  def index
    signet = Google::Auth.exchange_code params[:code]
    client = Google::Client.new signet
    email = client.get_user_info.data.email
    credentials = Credential.find_or_initialize_by email: email
    credentials.set_signet signet, email
  end
end
