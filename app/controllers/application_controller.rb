class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery
  before_filter :signed_in_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    session[:user_id].present?
  end

  def signed_in_user
    #THIS IS A HAAAACK!!!!!
    #Due to time limits we are using a hard coded API Tocken
    #TD-966 was added to the backlog to redress this woeful wrong
    #You will need to have a user with id 7 in the db this is to match ProvisionerUsername on Pantry
    if request.headers['X-Auth-Token'] == '00110011-0011-0011-0011-001100110011'
      session[:user_id] = 7
    end
    session['requested_url'] = request.url
    redirect_to '/auth/ldap', notice: "Please sign in." unless signed_in?
  end
end

