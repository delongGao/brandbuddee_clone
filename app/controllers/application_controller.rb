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

  def get_campaign_from_link_param
  	unless params[:campaign].blank?
  		params_campaign = params[:campaign].downcase
  		@campaign = Campaign.where(:link => params_campaign).first
  		unless @campaign.nil?
  			@brand = @campaign.brand
  			if @brand.nil?
  				render text: "An error occurred while trying to retrieve brand associated with the campaign you are looking for. Please refresh your page and try again."
  			end
  		else
  			render text: "The campaign you are looking for could not be found. Please contact the site owner for details."
  		end
		else
			render text: "There is a problem with the code used to install the embed widget to this page. Please have the site owner check the code, and then try again."
  	end
  end

  def require_super_admin_account
  	if current_user || Rails.env.development?
  		unless Rails.env.development? || current_user.account_type == 'super admin'
  			redirect_to root_url
  		end
  	else
  		redirect_to root_url
  	end
  end

  def require_admin_account
  	if current_user || Rails.env.development?
  		unless Rails.env.development? || current_user.account_type == 'super admin' || current_user.account_type == 'admin'
  			redirect_to root_url
  		end
  	else
  		redirect_to root_url
  	end
  end

  def require_mini_admin_account
  	if current_user || Rails.env.development?
  		unless Rails.env.development? || current_user.account_type == 'super admin' || current_user.account_type == 'admin' || current_user.account_type == 'mini admin'
  			redirect_to root_url
  		end
  	else
  		redirect_to root_url
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

  def str_is_valid_email(input)
  	if input.match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
			true
		else
			false
		end
	end
	helper_method :str_is_valid_email
end
