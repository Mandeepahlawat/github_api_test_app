class AuthenticationsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]

    if auth.present?
      authentication          = Auth.find_or_initialize_by(uid: auth.uid)
      authentication.username = auth.info.nickname
      authentication.provider = auth.provider
      authentication.token    = auth.credentials.token
      if authentication.save
        redirect_to users_path, notice: "Successfully authorized from github."
      else
        redirect_to root_url, notice: "Some problem has occured and you couldn't be authorized. Please try after some time."
      end
    end
  end
end