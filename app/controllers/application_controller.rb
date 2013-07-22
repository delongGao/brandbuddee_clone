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

  def current_brand
    @current_brand ||= Brand.find(session[:brand_id]) if session[:brand_id]
  end
  helper_method :current_brand

  def authorize_brand
    if current_brand.nil?
      flash[:error] = "You must be logged in as a brand to perform that action."
      redirect_to "/brands/login"
    end
  end

  def ensure_completed_brand_profile
    if current_brand.manager_first.blank? || current_brand.manager_last.blank? || current_brand.bio.blank? || current_brand.website.blank?
      flash[:info] = 'Please finish filling out your profile. These fields are used when displaying your campaign!'
      redirect_to "/brands/profile"
    end
  end
  
end
