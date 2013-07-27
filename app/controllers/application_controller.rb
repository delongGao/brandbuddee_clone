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

  def str_is_valid_url(input)
    if input.match(/\b((http(s?):\/\/)([a-z0-9\-]+\.)+(MUSEUM|TRAVEL|AERO|ARPA|ASIA|EDU|GOV|MIL|MOBI|COOP|INFO|NAME|BIZ|CAT|COM|INT|JOBS|NET|ORG|PRO|TEL|A[CDEFGILMNOQRSTUWXZ]|B[ABDEFGHIJLMNORSTVWYZ]|C[ACDFGHIKLMNORUVXYZ]|D[EJKMOZ]|E[CEGHRSTU]|F[IJKMOR]|G[ABDEFGHILMNPQRSTUWY]|H[KMNRTU]|I[DELMNOQRST]|J[EMOP]|K[EGHIMNPRWYZ]|L[ABCIKRSTUVY]|M[ACDEFGHKLMNOPQRSTUVWXYZ]|N[ACEFGILOPRUZ]|OM|P[AEFGHKLMNRSTWY]|QA|R[EOSUW]|S[ABCDEGHIJKLMNORTUVYZ]|T[CDFGHJKLMNOPRTVWZ]|U[AGKMSYZ]|V[ACEGINU]|W[FS]|Y[ETU]|Z[AMW])(:[0-9]{1,5})?((\/([a-z0-9_\-\.~]*)*)?((\/)?\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@\/?]*)?)/i)
      true
    else
      false
    end
  end
  helper_method :str_is_valid_url
  
end
