class SessionsController < ApplicationController
  
  def new
    if current_user
      flash[:notice] = "You are already signed in!"
      redirect_to root_url
    end
  end

  def create
    auth = request.env["omniauth.auth"]
    # check_user = User.exists?(provider: auth["provider"], uid: auth["uid"])

    if User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
      user = User.where(uid: auth["uid"]).first
      session[:user_id] = user.id
      redirect_to '/dashboard', :notice => "Signed in!"
    # elsif User.exists?(conditions: { twitter_handle: auth["user_info"]["nickname"] })
    #  user = User.where(twitter_handle: auth["user_info"]["nickname"]).first
    #  User.update_with_omniauth(auth, user)
    #  session[:user_id] = user.id
    #  redirect_to root_url, :notice => "Signed in!"
    else
      time_now = Time.now
      user = User.create_with_omniauth(auth, time_now)
      session[:user_id] = user.id
      #WelcomeMailer.welcome_email(current_user).deliver
      #redirect_to(:action => 'nickname')
      redirect_to root_url
    end
  end

  def email_create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      flash[:notice] = "Signed in!"
      #redirect_to root_url #, :notice => "Logged in!"
      redirect_to(:controller => 'users', :action => 'dashboard')
    else
      flash[:notice] = "Invalid email or password"
      redirect_to(:action => 'new')
    end
  end

  def destroy
    session[:user_id] = nil
    # redirect_to root_url, :notice => "Logged out!"
    flash[:notice] = "Logged out!"
    redirect_to root_url
  end
  
end
