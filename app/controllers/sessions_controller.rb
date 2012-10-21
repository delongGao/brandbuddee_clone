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
      user.last_login = Time.now
      user.save
      session[:user_id] = user.id
      redirect_to '/dashboard', :notice => "Signed in!"
    # elsif User.exists?(conditions: { twitter_handle: auth["user_info"]["nickname"] })
    #  user = User.where(twitter_handle: auth["user_info"]["nickname"]).first
    #  User.update_with_omniauth(auth, user)
    #  session[:user_id] = user.id
    #  redirect_to root_url, :notice => "Signed in!"
    else
      c = cookies[:invite]

      @invite = Invitation.where(:invite_code => c).first

      if @invite.nil?
        flash[:notice] = "Due to the unexpected amount of signups we have temporarily closed our beta. Feel free to sign up on the <a href='#{root_url}' style='color:green;'>beta list</a> to get an invite!"
        redirect_to "#{root_url}signup"
      else
        unless @invite.status == true
          email = cookies[:e]
          if auth["provider"] == "twitter"
            if email.nil?
              redirect_to(:controller => 'users', :action => 'complete_email')
            else
              user = User.create_with_omniauth_twitter(auth, Time.now, email)

              @invite.status = true
              @invite.success_date = Time.now
              @invite.save
              session[:user_id] = user.id
              #WelcomeMailer.welcome_email(current_user).deliver
              #redirect_to root_url
              redirect_to(:controller => 'users', :action => 'new')
            end
          else
            user = User.create_with_omniauth(auth, Time.now)

            @invite.status = true
            @invite.success_date = Time.now
            @invite.save
            session[:user_id] = user.id
            #WelcomeMailer.welcome_email(current_user).deliver
            #redirect_to root_url
            redirect_to(:controller => 'users', :action => 'new')
          end
        else
          flash[:notice] = "This invitation is no longer valid."
          redirect_to "#{root_url}signup"
        end
      end

    end
  end

  def email_create
    user = User.authenticate(params[:email], params[:password])
    if user
      user.last_login = Time.now
      user.save
      session[:user_id] = user.id
      flash[:notice] = "Signed in!"
      #redirect_to root_url #, :notice => "Logged in!"
      #redirect_to(:controller => 'users', :action => 'dashboard')
      respond_to do |format|
        format.html
        format.js
      end
    else
      flash[:notice] = "Invalid email or password"
      #redirect_to(:action => 'new')
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def destroy
    session[:user_id] = nil
    # redirect_to root_url, :notice => "Logged out!"
    flash[:notice] = "Logged out!"
    redirect_to root_url
  end
  
end