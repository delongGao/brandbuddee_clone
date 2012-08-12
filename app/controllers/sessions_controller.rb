class SessionsController < ApplicationController
  
  def new
    if current_user
      flash[:notice] = "You are already signed in!"
      redirect_to root_url
    end
  end

  def create
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
