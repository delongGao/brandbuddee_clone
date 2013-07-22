class ResetPasswordsController < ApplicationController
  def new
  end

  def create
  	brand = Brand.where(email: params[:email_address]).first
    if brand && brand.provider=="email"
  	 brand.send_reset_password
    end
  	flash[:info] = "Email sent with password reset instructions."
  	redirect_to "/reset_passwords/new"
  end

  def edit
  	@brand = Brand.where(password_reset_token: params[:id]).first
  	if @brand.nil?
  		flash[:error] = "The brand associated with that password reset link could not be found. Please try resending the password reset email."
  		redirect_to "/reset_passwords/new"
  	end
  end

  def update
  	@brand = Brand.where(password_reset_token: params[:id]).first
  	if @brand.nil?
  		flash[:error] = "The brand associated with that password reset link could not be found. Please try resending the password reset email."
  		redirect_to "/reset_passwords/new"
  	else
  		if @brand.password_reset_sent_at < 2.hours.ago
  			flash[:error] = "This password reset has expired. Please request a new one."
  			redirect_to "/reset_passwords/new"
  		else
  			if params[:brand][:password].blank? || !params[:brand][:password].length.between?(6,30)
  				@brand.errors.add(:password, "must be between 6-30 characters in length.")
  				render :edit
  			else
  				if params[:brand][:password_confirmation].blank? || params[:brand][:password] != params[:brand][:password_confirmation]
  					@brand.errors.add(:password_confirmation, "does not match the password.")
  					render :edit
  				else
	  				if @brand.update_attributes(params[:brand])
	  					flash[:info] = "Your password has been reset!"
	  					redirect_to "/reset_passwords/new"
	  				else
	  					render :edit
	  				end
	  			end
	  		end
	  	end
  	end
  end
end
