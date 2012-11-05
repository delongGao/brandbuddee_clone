class UsersController < ApplicationController
  #before_filter :confirm_user_logged_in
  
  def dashboard
    if current_user

      #@campaign = Campaign.all.order_by([:date, :desc])
      @categories = Category.all.order_by([:name, :asc])

      #if current_user.email == 'email@email.com'
      if current_user.email.nil? || current_user.email.blank?
        redirect_to(:action => 'complete_email')
      end

      current_user.last_activity = Time.now
      current_user.save

    else
      redirect_to root_url
    end
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

  def password_resets_show
    @password_resets = PasswordReset.all.order_by([:date, :asc])
  end

  def password_reset
    #password reset request
    @password_reset = PasswordReset.new
  end

  def password_reset_update
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
    @user = User.new(params[:user])
    @invite = Invitation.where(:invite_code => params[:invite]).first

    if @invite.nil?
      flash[:notice] = "Due to the unexpected amount of signups we have temporarily closed our beta. Feel free to sign up on the <a href='#{root_url}' style='color:green;'>beta list</a> to get an invite!"
      redirect_to "#{root_url}signup"
    else
      unless @invite.status == true
        if @user.save
          session[:user_id] = @user.id

          @invite.status = true
          @invite.success_date = Time.now
          @invite.save

          flash[:notice] = "Signed up!"
          redirect_to(:controller => 'users', :action => 'dashboard')
        else
          unless params[:invite].blank?
            flash[:notice] = "fuuuuuu #{params[:invite]} | #{@invite.email}"
            redirect_to "#{root_url}signup?invite=#{params[:invite]}"
          else
            flash[:notice] = "Invalid... please fill out all the fields."
            redirect_to "#{root_url}signup"
          end
        end
      else
        flash[:notice] = "This invitation is no longer valid."
        redirect_to "#{root_url}signup"
      end
    end

  end
  
  def show
    if current_user
      if current_user.account_type == "admin"
          @user = User.all.order_by([:date, :desc])
          @campaign_all = Campaign.all.order_by([:date, :desc])
          @category_all = Category.all.order_by([:date, :desc])
          @location_all = Location.all.order_by([:date, :desc])
          @brand_all = Brand.all.order_by([:date, :desc])
          @share_all = Share.all.order_by([:date, :desc])
          @redeem_all = Redeem.all.order_by([:date, :desc])
          @link = Campaign.assign_link()
      else
        redirect_to root_url
      end
    else
      redirect_to root_url
    end
  end

  def create_new_campaign
    @brand = Brand.find(params[:brands])
    @campaign = @brand.campaigns.create!(params[:campaign])

    unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
      date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
      @campaign.end_date = date_time
    end

    if params[:campaign][:tweet].blank?
      @campaign.tweet = "Check out #{@campaign.title} via @brandbuddee"
    end

    category = Category.find(params[:categories])
    @campaign.category_ids << params[:categories]
    @campaign.location = params[:location]

    if @campaign.save
      flash[:notice] = "Campaign successfully created"
      redirect_to(:action => 'show')
    else
      flash[:notice] = "Uh oh"
    end

  end

  def create_new_category
    @category = Category.create!(params[:category])

    if @category.save
      flash[:notice] = "Category successfully created"
      redirect_to(:action => 'show')
    else
      flash[:notice] = "Uh oh"
    end
  end

  def create_new_location
    @location = Location.create!(params[:location])

    if @location.save
      flash[:notice] = "Location successfully created"
      redirect_to(:action => 'show')
    else
      flash[:notice] = "Uh oh"
    end
  end

  def create_new_brand
    @brand = Brand.create!(params[:brand])

    if @brand.save
      flash[:notice] = "Brand successfully created"
      redirect_to(:action => 'show')
    else
      flash[:notice] = "Uh oh"
    end
  end

  def edit_brand
    @brand = Brand.find(params[:_id])
  end

  def update_brand
    @brand = Brand.find(params[:brand][:id])

    if @brand.update_attributes(params[:brand])
      flash[:notice] = "Successfully updated."
      redirect_to "#{root_url}admin/brand/edit?_id=#{params[:brand][:id]}"
    else
      flash[:notice] = "Uh oh... something went wrong. Please try again."
      redirect_to "#{root_url}admin/brand/edit?_id=#{params[:brand][:id]}"
    end
  end

  def brand_destroy
    @brand = Brand.find(params[:_id])
    @brand.destroy
    flash[:notice] = "#{@brand.name} brand Destroyed"
    redirect_to(:action => 'show')
  end

  def category_destroy
    @category = Category.find(params[:_id])
    @category.destroy
    flash[:notice] = "#{@category.name} Category Destroyed"
    redirect_to(:action => 'show')
  end

  def location_destroy
    @location = Location.find(params[:_id])
    @location.destroy
    flash[:notice] = "#{@location.city} Location Destroyed"
    redirect_to(:action => 'show')
  end

  def campaign_destroy
    @campaign = Campaign.find(params[:_id])
    @campaign.destroy
    flash[:notice] = "#{@campaign.title} campaign Destroyed"
    redirect_to(:action => 'show')
  end

  def share_destroy
    @share = Share.find(params[:_id])
    @share.destroy
    flash[:notice] = "Share Link: #{@share.link} Destroyed"
    redirect_to(:action => 'show')
  end

  def redeem_destroy
    @redeem = Redeem.find(params[:_id])
    @redeem.destroy
    flash[:notice] = "Redeem Destroyed"
    redirect_to(:action => 'show')
  end

  def password_resets_destroy
    @password_reset = PasswordReset.find(params[:_id])
    @password_reset.destroy
    flash[:notice] = "Password Reset Request Destroyed"
    redirect_to(:action => 'password_resets_show')
  end
  
  def destroy
    @user = User.find(params[:_id])
    @user.destroy
    session[:user_id] = nil
    flash[:notice] = "User Destroyed"
    redirect_to(:action => 'show')
  end
  
end
