class AdminController < ApplicationController

	def index

		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
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

	def campaigns
		@campaigns = Campaign.all.order_by([:date, :desc])
	end

	def view_campaign
		@campaign = Campaign.find(params[:_id])

		@share_month = Share.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id])
		@share_two_months = Share.where(:date.gt => Time.now - 2.month, :campaign_id => params[:_id])
		@share_month_count = @share_month.count
		@share_last_month_count = @share_two_months.count - @share_month_count



		#@users_weekly = User.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
		@users_weekly = @campaign.users.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])

		share_ids = Share.where(:campaign_id => params[:_id]).map(&:_id)
		@trackings_weekly = Tracking.where(:share_id.in => share_ids)
		#@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
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
	end

	def edit_campaign
		@category_all = Category.all.order_by([:date, :desc])
    	@brand_all = Brand.all.order_by([:name, :asc])
    	@location_all = Location.all.order_by([:city, :desc])

		@campaign = Campaign.find(params[:_id])
	end

	def update_campaign
		@campaign = Campaign.find(params[:campaign][:id])
		
		unless params[:brand].blank?
			@campaign.brand_id = params[:brand]
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
	      flash[:notice] = "Successfully updated."
	      #redirect_to(:action => 'edit_campaign')
	      redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to(:action => 'edit_campaign')
	    end
	end

end
