class UsersController < ApplicationController
  #before_filter :confirm_user_logged_in
  
  def dashboard
    if current_user

      #@campaign = Campaign.all.order_by([:date, :desc])
      @categories = Category.all.order_by([:name, :asc])

      if current_user.email == 'email@email.com'
        redirect_to(:action => 'complete_email')
      end

    else
      redirect_to root_url
    end
  end

  def complete_email
    @user = User.find(current_user.id)
  end

  def complete_email_update
    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      redirect_to root_url
    else
      flash[:notice] = "Uh oh... something went wrong. Please try again."
      redirect_to root_url
    end
  end

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
      # => redirect_to(:action => 'new')
    end
  end
  
  def show
    if current_user
      if current_user.account_type == "admin"
          @user = User.all.order_by([:date, :desc])
          @campaign_all = Campaign.all.order_by([:date, :desc])
          @category_all = Category.all.order_by([:date, :desc])
          @brand_all = Brand.all.order_by([:date, :desc])
          @share_all = Share.all.order_by([:date, :desc])
          @redeem_all = Redeem.all.order_by([:date, :desc])
          #@link = Campaign.assign_link()
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

    category = Category.find(params[:categories])
    @campaign.category_ids << params[:categories]

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

  def create_new_brand
    @brand = Brand.create!(params[:brand])

    if @brand.save
      flash[:notice] = "Brand successfully created"
      redirect_to(:action => 'show')
    else
      flash[:notice] = "Uh oh"
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
  
  def destroy
    @user = User.find(params[:_id])
    @user.destroy
    session[:user_id] = nil
    flash[:notice] = "User Destroyed"
    redirect_to(:action => 'show')
  end
  
end
