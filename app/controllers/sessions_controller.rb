class SessionsController < ApplicationController
  def new
     
  end

  def create
     user = User.from_omniauth(env['omniauth.auth'])
     session[:user_id]= user.id   
     redirect_to root_url, notice: "Signed in!"
  end

   def failure
    redirect_to '/auth/ldap', notice: "Authentication failed, please try again."
   end
   
   def destroy
    session[:user_id] = nil
    redirect_to '/auth/ldap', notice: "Signed out!"
   end
end
