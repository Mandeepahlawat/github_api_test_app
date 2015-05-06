class UsersController < ApplicationController
  def index
  	@users = User.all
  	@user = User.new
  end

  def create
  	usernames = params[:user][:username].gsub(/\s+/, "").split(",") #get list of comma seprated users and remove any spaces
  	usernames.each {|username| User.check_user_and_get_activity(username)} #check if user exits and if exists then create one
  	@users 	= User.all  
  end
end
