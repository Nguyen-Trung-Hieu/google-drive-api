class Credential < ActiveRecord::Base
  def set_credentials signet, email
    update_attributes signet: signet.to_json, email: email
  end
end
