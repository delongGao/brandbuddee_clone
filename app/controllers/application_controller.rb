class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  
  private
  
  def confirm_user_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'sessions', :action => 'new')
      return false # halts the before_filter
    else
      return true
    end
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
end
