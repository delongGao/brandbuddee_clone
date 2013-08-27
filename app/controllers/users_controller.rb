class UsersController < ApplicationController
  #before_filter :confirm_user_logged_in
  
  def dashboard
    if current_user
      if current_user.email.nil? || current_user.email.blank?
        redirect_to(:action => 'complete_email')
      elsif current_user.nickname.nil? || current_user.nickname.blank?
        redirect_to(:action => 'choose_username')
      else
        current_user.last_activity = Time.now
        current_user.save
        c = Campaign.all.order_by([:date, :desc])
        c.each do |campaign_filter|
          if campaign_filter.end_date.nil?
            campaign_filter.end_date = campaign_filter.date + 1.month
            unless campaign_filter.left == false
              campaign_filter.status = "active"
            else
              campaign_filter.status = "expired" unless campaign_filter.redeem_is_raffle
            end
          else
            if campaign_filter.end_date < Time.now || (!campaign_filter.redeem_is_raffle && campaign_filter.left == false)
              campaign_filter.status = "expired"
            else
              campaign_filter.status = "active"
            end
          end
          campaign_filter.save(validate: false)
          if campaign_filter.limit.nil?
            campaign_filter.limit = 0
            campaign_filter.left = false
          else
            left_status = campaign_filter.limit - campaign_filter.redeems.size
            if left_status == 0
              campaign_filter.left = false unless campaign_filter.redeem_is_raffle
            else
              campaign_filter.left = true
            end
          end
          campaign_filter.save(validate: false)
        end # c.each do |campaign_filter|
        if params[:c].nil?
          @campaign = Campaign.where(:status => "active").excludes(left: false, is_white_label: true).order_by([:date, :desc]).paginate :page => params[:page], :per_page => 9
        else
          @category = Category.where(:name => params[:c]).first
          unless @category.nil?
          	@campaign = @category.campaigns.where(:status => "active").excludes(left: false, is_white_label: true).order_by([:date, :desc]).paginate :page => params[:page], :per_page => 9
          else
          	flash[:error] = "The Campaign Category you are looking for could not be found."
          	redirect_to "/home"
          end
        end
        @categories = Category.all.order_by([:name, :asc])
      end
    elsif current_brand
      redirect_to "/brands/dashboard"
    else
      redirect_to root_url
    end
  end

  def facebook_connect
    auth = request.env["omniauth.auth"]

    User.update_with_omniauth(auth, current_user)

    flash[:notice] = "Successfully connected with Facebook"
    redirect_to '/home'
  end

  def campaign_newsletter
    if current_user
      if current_user.account_type == 'super admin' || Rails.env.development?
        #user = User.find('50cb767e858e4a4fce000001')
        #UserMailer.campaign_newsletter(user.email, root_url).deliver

        # Subscriber.delay.campaign_newsletter_push(root_url)
        Subscriber.delay.new_campaign_newsletter_push(root_url)

        flash[:notice] = "Campaign newsletter successfully delivered."
        redirect_to(:controller => 'users', :action => 'campaign_newsletter_confirmation')
      else
        redirect_to root_url
      end
    else
      redirect_to root_url
    end
  end

  def campaign_newsletter_confirmation
  end

  def complete_email
    @user = User.first
  end

  def complete_email_update
    email = params[:email]

    if email.match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i).nil?
      flash[:notice] = "Invalid Email"
      redirect_to(:action => 'complete_email')
    elsif User.validates_email_uniqueness(email)
      flash[:notice] = "This email is already associated with an account."
      redirect_to(:action => 'complete_email')
    else
      cookies[:e] = { :value => email, :expires => Time.now + 3600 }
      redirect_to '/auth/twitter'
    end

  end

  def choose_username
    if current_user
      @user = User.find(current_user.id)
      if current_user.nickname.nil? || current_user.nickname.blank?
      else
        redirect_to root_url
      end
    else
      flash[:error] = "You must be logged in as a buddee to perform that action."
      redirect_to root_url
    end
  end

  def choose_username_update
    @user = User.find(current_user.id)
    user_nickname_before = params[:user][:nickname]

      nickname_regex = /^[a-zA-Z0-9_\s]*$/i
      if user_nickname_before.match(/^[a-zA-Z0-9_\s]*$/i).nil?
        flash[:notice] = "Invalid username! Alphanumerics only."
        redirect_to(:controller => 'users', :action => 'choose_username')
      else
        if user_nickname_before.blank?
          flash[:notice] = "Username can't be blank"
          redirect_to(:controller => 'users', :action => 'choose_username')
      else
          if user_nickname_before.nil? || user_nickname_before == ""
            user_nickname_after = nil
          elsif user_nickname_before != nil
            user_nickname_after = user_nickname_before.downcase
          end

          check_exist = User.first(conditions: { nickname: user_nickname_after})
          if check_exist != nil
            if @user.nickname == user_nickname_after
              flash[:notice] = "This is your current username"
              redirect_to(:controller => 'users', :action => 'choose_username')
            elsif check_exist.nickname != nil
              flash[:notice] = "Username already exists. Please try another."
              redirect_to(:controller => 'users', :action => 'choose_username')
            elsif check_exist.nickname == nil
              flash[:notice] = "Please choose a username."
              redirect_to(:controller => 'users', :action => 'choose_username')
            end
          elsif check_exist == nil
            @user.nickname = user_nickname_after
            if @user.save
              flash[:notice] = "Username successfully updated."
              redirect_to(:controller => 'users', :action => 'choose_username')
          else
              flash[:notice] = "Uh oh... something went wrong. Please try again."
              redirect_to(:controller => 'users', :action => 'choose_username')
          end
            #flash[:notice] = "Nickname is now yours!"
          end
      end
    end
  end

  def choose_location
    @user = User.find(current_user.id)
    if current_user.location.nil? || current_user.location.blank?
    else
      redirect_to root_url
    end
  end

  def choose_location_update
    @user = User.find(current_user.id)
    #@location = Location.find(params[:location])
    #@user.location_id = @location.id
    @user.location = params[:user][:location]

    if @user.save
        flash[:notice] = "Location updated"
        redirect_to root_url
      else
        flash[:notice] = "Location was not updated. Please try again"
        redirect_to(:action => 'choose_location')
      end
  end

  def password_resets_show
    @password_resets = PasswordReset.all.order_by([:date, :asc])
  end

  def password_reset
    unless current_brand
      @password_reset = PasswordReset.new
    else
      flash[:error] = "You cannot be logged in as a brand and perform that action."
      redirect_to "/brands/dashboard"
    end
  end

  def password_reset_update
  	unless params[:password_reset].nil?
	    email = params[:password_reset][:email]

	    if email.match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i).nil?
	      flash[:notice] = "Invalid Email"
	      redirect_to(:action => 'password_reset')
	    else
	      @user = User.where(:email => params[:password_reset][:email]).first

	      if @user.nil?
	        flash[:notice] = "This email is not associated with a brandbuddee account. Please try another email address."
	        redirect_to(:action => 'password_reset')
	      elsif @user != nil && @user.provider == nil
	        @password_reset = PasswordReset.create!(params[:password_reset])
	        @password_reset.date = Time.now
	        @password_reset.name = @user.first_name
	        hash_code = PasswordReset.assign_hash()
	        @password_reset.hash_code = hash_code.to_s

	        if @password_reset.save
	          UserMailer.password_reset(@password_reset, root_url).deliver
	          flash[:notice] = "Password reset sent to <b>#{params[:password_reset][:email]}</b>"
	          redirect_to(:action => 'password_reset')
	        else
	          flash[:notice] = "Please try again..."
	          redirect_to(:action => 'password_reset')
	        end
	      else
	        flash[:notice] = "This email is not associated with a brandbuddee account created via email. Please try another email."
	        redirect_to(:action => 'password_reset')
	      end
	    end
	else
		flash[:notice] = "You must enter your email address to reset your password. Please try again."
		redirect_to "/password/reset"
	end
  end

  def password_reset_submit
    @password_reset = PasswordReset.where(:hash_code => params[:hash_code]).first
  end

  def password_reset_submit_update
    @password_reset = PasswordReset.where(:hash_code => params[:hash_code]).first

    if params[:password_reset][:password].blank? || params[:password_reset][:password_confirmation].blank?
      flash[:notice] = "Please complete all fields"
      redirect_to '/pw/reset/' + @password_reset.hash_code
    elsif params[:password_reset][:password] != params[:password_reset][:password_confirmation]
      flash[:notice] = "New password and confirmation must match"
      redirect_to '/pw/reset/' + @password_reset.hash_code
    else
      @password_reset.reset_date = Time.now
      @password_reset.status = true
      @password_reset.save

      @user = User.where(:email => @password_reset.email).first

      if @user.update_attributes(params[:password_reset])
        flash[:notice] = "Successfully updated."
        #redirect_to(:controller => 'profile', :action => 'login')
        redirect_to root_url
      else
        flash[:notice] = "Uh oh... something went wrong. Please try again."
        #redirect_to(:controller => 'profile', :action => 'profile_settings')
        redirect_to '/pw/reset/' + @password_reset.hash_code
      end
    end
  end

  def new
    if current_user
      redirect_to root_url
    else
      @user = User.new
      cookies[:invite] = params[:invite]
    end
  end

  def create
    unless current_brand
      # @user = User.new(params[:user])
      @user = User.create(params[:user])
      # @invite = Invitation.where(:invite_code => params[:invite]).first

      # if @invite.nil?
      #   flash[:notice] = "Due to the unexpected amount of signups we have temporarily closed our beta. Feel free to sign up on the <a href='#{root_url}' style='color:green;'>beta list</a> to get an invite!"
      #   redirect_to "#{root_url}signup"
      # else
      #   unless @invite.status == true
          if @user.save
            session[:user_id] = @user.id

            # @invite.status = true
            # @invite.success_date = Time.now
            # @invite.save

            flash[:notice] = "Signed up!"
            redirect_to(:controller => 'users', :action => 'dashboard')
          else
          #   unless params[:invite].blank?
          #     flash[:notice] = "Invalid invitation."
          #     redirect_to "#{root_url}signup?invite=#{params[:invite]}"
          #   else
              flash[:notice] = "Invalid... please fill out all the fields."
              redirect_to "#{root_url}signup"
          #   end
          end
        # else
        #   flash[:notice] = "This invitation is no longer valid."
        #   redirect_to "#{root_url}signup"
        # end
      # end
    else
      flash[:error] = "You are already logged in as a brand. You can't sign up as a buddee."
      redirect_to "/brands/dashboard"
    end
  end

  def password_resets_destroy
    if current_user || Rails.env.development?
      if current_user.account_type=="super admin" || Rails.env.development?
        @password_reset = PasswordReset.find(params[:_id])
        @password_reset.destroy
        flash[:notice] = "Password Reset Request Destroyed"
        redirect_to(:action => 'password_resets_show')
      else
        redirect_to root_url
      end
    else
      redirect_to root_url
    end
  end
  
  def destroy
    if current_user || Rails.env.development?
      if current_user.account_type=="super admin" || Rails.env.development?
        @user = User.find(params[:_id])
        @user.destroy
        session[:user_id] = nil
        flash[:notice] = "User Destroyed"
        redirect_to(:action => 'show')
      else
        redirect_to root_url
      end
    else
      redirect_to root_url
    end
  end
  
end
