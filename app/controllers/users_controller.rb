class UsersController < ApplicationController
  before_filter :confirm_user_logged_in
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Signed up!"
      redirect_to(:controller => 'users', :action => 'dashboard')
    else
      render "new"
    end
  end
  
  def show
    @user = User.all.order_by([:date, :desc])
  end
  
  def destroy
    @user = User.find(params[:_id])
    @user.destroy
    session[:user_id] = nil
    flash[:notice] = "User Destroyed"
    redirect_to(:action => 'show')
  end
  
end
