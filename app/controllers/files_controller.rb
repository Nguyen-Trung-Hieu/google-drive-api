class FilesController < ApplicationController
  def index
    @url = Google::Auth.get_authorization_url
  end
end
