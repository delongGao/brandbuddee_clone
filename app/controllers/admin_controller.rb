class AdminController < ApplicationController

	def index

		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@share_month = Share.where(:date.gt => Time.now - 1.month)
				@share_two_months = Share.where(:date.gt => Time.now - 2.month)
				@share_month_count = @share_month.count
				@share_last_month_count = @share_two_months.count - @share_month_count

				@user_month = User.where(:date.gt => Time.now - 1.month)
				@user_two_months = User.where(:date.gt => Time.now - 2.month)
				@user_month_count = @user_month.count
				@user_last_month_count = @user_two_months.count - @user_month_count

				@trackings_month = Tracking.where(:date.gt => Time.now - 1.month)
				@trackings_two_months = Tracking.where(:date.gt => Time.now - 2.month)
				#@user_this_month = User.where(:date.gt => Time.now - 1.month, :date.lte => Time.now)

				#@share_views_month = 0
				# @share_month.each do |s|
				# 	@share_views_month = @share_views_month + s.unique_page_views + s.trackings.size
				# end
				#@share_views_last_month = 0
				# views_last_month = @share_month - @share_two_months
				# views_last_month.each do |s|
				# 	@share_views_last_month = @share_views_last_month + s.unique_page_views + s.trackings.size
				# end
				#@views_month_count = 
				@views_last_month_count = @user_two_months.count - @user_month_count


				@users_weekly = User.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@redeems_weekly = Redeem.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@campaigns_weekly = Campaign.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@brands_weekly = Brand.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])

				@last_users = User.all.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4

				@user_all = User.all.order_by([:date, :desc])
				@campaign_all = Campaign.all.order_by([:date, :desc])
				@category_all = Category.all.order_by([:date, :desc])
				@location_all = Location.all.order_by([:date, :desc])
				@brand_all = Brand.all.order_by([:date, :desc])
				@share_all = Share.all.order_by([:date, :desc])
				@tracking_all = Tracking.all.order_by([:date, :desc])
				@redeem_all = Redeem.all.order_by([:date, :desc])

				

			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end

	end

	def users
		@users = User.all.order_by([:date, :desc])
	end

	def campaigns
		@campaigns = Campaign.all.order_by([:date, :desc])
		@location_all = Location.all.order_by([:name, :asc])
		@category_all = Category.all.order_by([:name, :asc])
		@brand_all = Brand.all.order_by([:name, :asc])
		@link = Campaign.assign_link()
	end

	def campaign_delete
		@campaign = Campaign.find(params[:_id])
		@campaign.destroy
		flash[:notice] = "#{@campaign.title} campaign Destroyed"
		redirect_to(:action => 'campaigns')
	end

	def campaign_new
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
	      redirect_to(:action => 'campaigns')
	    else
	      flash[:notice] = "Uh oh"
	    end
	end

	def locations
		@locations = Location.all.order_by([:date, :desc])
	end

	def location_new
		@location = Location.create!(params[:location])

	    if @location.save
	      flash[:notice] = "Location successfully created"
	      redirect_to(:action => 'locations')
	    else
	      flash[:notice] = "Uh oh"
	    end
	end

	def location_delete
		@location = Location.find(params[:_id])
		@location.destroy
		flash[:notice] = "#{@location.city} Location Destroyed"
		redirect_to(:action => 'locations')
	end

	def redeems
		@redeems = Redeem.all.order_by([:date, :desc])
	end

	def categories
		@categories = Category.all.order_by([:date, :desc])
	end

	def category_new
		@category = Category.create!(params[:category])

	    if @category.save
	      flash[:notice] = "Category successfully created"
	      redirect_to(:action => 'categories')
	    else
	      flash[:notice] = "Uh oh"
	    end
	end

	def category_delete
		@category = Category.find(params[:_id])
	    @category.destroy
	    flash[:notice] = "#{@category.name} Category Destroyed"
	    redirect_to(:action => 'categories')
	end

	def brands
		@brands = Brand.all.order_by([:date, :desc])
	end

	def brand_new
		@brand = Brand.create!(params[:brand])

	    if @brand.save
	      flash[:notice] = "Brand successfully created"
	      redirect_to(:action => 'brands')
	    else
	      flash[:notice] = "Uh oh"
	    end
	end

	def brand_edit
		@brand = Brand.find(params[:_id])
	end

	def brand_update
		@brand = Brand.find(params[:brand][:id])

		if @brand.update_attributes(params[:brand])
		  flash[:notice] = "Successfully updated."
		  redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
		else
		  flash[:notice] = "Uh oh... something went wrong. Please try again."
		  redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
		end
	end

	def brand_delete
		@brand = Brand.find(params[:_id])
	    @brand.destroy
	    flash[:notice] = "#{@brand.name} brand Destroyed"
	    redirect_to(:action => 'brands')
	end

	def view_campaign
		@campaign = Campaign.find(params[:_id])

		@share_month = Share.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id])
		@share_two_months = Share.where(:date.gt => Time.now - 2.month, :campaign_id => params[:_id])
		@share_month_count = @share_month.count
		@share_last_month_count = @share_two_months.count - @share_month_count



		#@users_weekly = User.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
		#@users_weekly = @campaign.users.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
		@users_weekly = Share.where(:date.gt => Time.now - 1.week, :campaign_id => params[:_id])

		share_ids = Share.where(:campaign_id => params[:_id]).map(&:_id)
		@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week, :share_id.in => share_ids)
		#@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
		@redeems_weekly = Redeem.where(:date.gt => Time.now - 1.week, :campaign_id => params[:_id]).order_by([:date, :desc])

		@users_monthly = Share.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id])
		@trackings_monthly = Tracking.where(:date.gt => Time.now - 1.month, :share_id.in => share_ids)
		@redeems_monthly = Redeem.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id]).order_by([:date, :desc])

		#@last_users = User.all.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4
		@last_users = @campaign.users.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4

		@user_all = Share.where(:campaign_id => params[:_id])
		@share_all = Share.all.order_by([:date, :desc])
		@tracking_all = Tracking.where(:share_id.in => share_ids)
		@redeem_all = @campaign.redeems
	end

	def edit_campaign
		@category_all = Category.all.order_by([:name, :asc])
    	@brand_all = Brand.all.order_by([:name, :asc])
    	@location_all = Location.all.order_by([:city, :desc])

		@campaign = Campaign.find(params[:_id])
	end

	def update_campaign
		@campaign = Campaign.find(params[:campaign][:id])
		
		unless params[:brand].blank?
			@campaign.brand_id = params[:brand]
		end

		unless params[:category].blank?
			# @campaign.category_ids << params[:brand]
			# @campaign.save

			@campaign.categories.clear
			category = Category.find(params[:category])
			@campaign.categories << category
		end

		unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
			date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
			@campaign.end_date = date_time
		end
		
		unless params[:campaign][:location].blank?
			@location = Location.find(params[:campaign][:location])
			@campaign.location_id = @location.id
		end

	    if @campaign.update_attributes(params[:campaign])
	      flash[:notice] = "Successfully updated. #{params[:category]}"
	      #redirect_to(:action => 'edit_campaign')
	      redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to(:action => 'edit_campaign')
	    end

		# @campaign = Campaign.find(params[:campaign][:id])
		
		# unless params[:brand].blank?
		# 	@campaign.brand_id = params[:brand]
		# end

		# unless params[:category].blank?
		# 	@campaign.categories << params[:category]
		# end

		# unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
		# 	date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
		# 	@campaign.end_date = date_time
		# end
		
		# unless params[:campaign][:location].blank?
		# 	@location = Location.find(params[:campaign][:location])
		# 	@campaign.location_id = @location.id
		# end

	 #    if @campaign.update_attributes(params[:campaign])
	 #      flash[:notice] = "Successfully updated. #{params[:brand]} b"
	 #      #redirect_to(:action => 'edit_campaign')
	 #      redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
	 #    else
	 #      flash[:notice] = "Uh oh... something went wrong. Please try again."
	 #      redirect_to(:action => 'edit_campaign')
	 #    end
	end

	def view_campaign_users
		@campaign = Campaign.find(params[:_id])
		@campaign_users = @campaign.users.order_by([:date, :desc])
	end

	def view_campaign_redeems
		@campaign = Campaign.find(params[:_id])
		@campaign_redeems = @campaign.redeems.order_by([:date, :desc])
	end

	def view_campaign_trackings
		@campaign = Campaign.find(params[:_id])
		share_ids = Share.where(:campaign_id => @campaign._id).map(&:_id)

		@campaign_trackings = Tracking.where(:share_id.in => share_ids).order_by([:date, :desc])
	end

end
