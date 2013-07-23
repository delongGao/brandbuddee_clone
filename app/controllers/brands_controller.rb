class BrandsController < ApplicationController
	before_filter :authorize_brand, except: [:facebook_auth, :twitter_auth]	
	before_filter :ensure_completed_brand_profile, except: [:facebook_auth, :twitter_auth, :view_edit_profile, :update_profile]
	def facebook_auth
		session[:account_type] = "brand"
		redirect_to '/auth/facebook'
	end

	def twitter_auth
		session[:account_type] = "brand"
		redirect_to '/auth/twitter'
	end

	def dashboard
		@brand = Brand.find(@current_brand.id)
		@num_of_redeems = 0
		@brand.campaigns.each do |c|
			@num_of_redeems += c.redeems.count
		end
		@users_list = []
		@total_pinterest_clicks = 0
		@total_twitter_clicks = 0
		@total_facebook_clicks = 0
		@total_tumblr_clicks = 0
		@total_social_clicks = 0
		@brand.campaigns.each do |c|
			@total_pinterest_clicks += c.pinterest_clicks
			@total_twitter_clicks += c.twitter_clicks
			@total_facebook_clicks += c.facebook_clicks
			@total_tumblr_clicks += c.tumblr_clicks
			@total_social_clicks += @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks
			c.users.each do |u|
				@users_list << u
			end
		end
		@users_list = @users_list.uniq.last(5)
	end

	def view_edit_profile
		@brand = Brand.find(@current_brand.id)
	end

	def update_profile
		@brand = Brand.find(@current_brand.id)
		begin
			if !params[:brand][:remove_brand_logo].nil? && params[:brand][:remove_brand_logo] == "1"
				@brand.remove_brand_logo!
				@brand.brand_logo = nil
				@brand.save!(validate: false)
			end
			@brand.attributes = params[:brand]
			@brand.last_updated = DateTime.now
			if @brand.save
				if !session[:brand_profile_unfinished].nil? && session[:brand_profile_unfinished].to_s == "true"
					session[:brand_profile_unfinished] = nil
					BrandMailer.profile_completion(@brand, root_url).deliver
				end
				flash[:info] = "Your Brand Profile has been updated!"
				redirect_to "/brands/profile"
			else
				render "view_edit_profile"
			end
		rescue OpenURI::HTTPError
			flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
			redirect_to "/brands/profile"
		rescue CarrierWave::IntegrityError
			flash[:error] = "The URL you are trying to upload an image from does not appear to point to an image file. You may only use the following file types: .jpg, .jpeg, .gif, & .png"
			redirect_to "/brands/profile"
		rescue CarrierWave::DownloadError
			flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
			redirect_to "/brands/profile"
		rescue CarrierWave::InvalidParameter
			flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
			redirect_to "/brands/profile"
		rescue CarrierWave::ProcessingError
			flash[:error] = "An error occured while processing the image you wish to upload from the web. Are you sure the URL points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
			redirect_to "/brands/profile"
		rescue CarrierWave::UploadError
			flash[:error] = "The URL you are trying to upload an image from caused an error. Are you sure it points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
			redirect_to "/brands/profile"
		end
	end

	def change_password
		if @current_brand.provider == "email"
			@brand = Brand.find(@current_brand.id)
		else
			redirect_to "/brands/dashboard"
		end
	end

	def update_password
		@brand = Brand.find(@current_brand.id)
		if !params[:brand][:password].blank? && params[:brand][:password].length.between?(6,30)
			if !params[:brand][:password_confirmation].blank? && params[:brand][:password] === params[:brand][:password_confirmation]
				if @brand.update_attributes(params[:brand])
					@brand.current_password = nil
					@brand.save(validate: false)
					flash[:info] = "Your brand password has been changed!"
					redirect_to "/brands/dashboard"
				else
					render "change_password"
				end
			else
				@brand.errors.add(:password_confirmation, "does not match the password.")
				render "change_password"
			end
		else
			@brand.errors.add(:password, "must be between 6-30 characters in length.")
			render "change_password"
		end		
	end

	def change_email
		@brand = Brand.find(@current_brand.id)
	end

	def update_email
		@brand = Brand.find(@current_brand.id)
		if @brand.update_attributes(params[:brand])
			@brand.last_updated = DateTime.now
			@brand.save(validate: false)
			flash[:info] = "Your brand email address has been updated!"
			redirect_to "/brands/dashboard"
		else
			render "change_email"
		end
	end

	def list_campaigns
		@brand = Brand.find(@current_brand.id)
	end

	def view_campaign
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			share_month_count = Share.where(:date.gt => Time.now - 1.month, :campaign_id => @campaign.id).count
			share_two_months = Share.where(:date.gt => Time.now - 2.month, :campaign_id => @campaign.id).count
			share_last_month_count = share_two_months - share_month_count
			share_change = share_month_count - share_last_month_count
			if share_last_month_count == 0
				share_last_month_count = 1
			end
			@share_percentage = (share_change.to_f/share_last_month_count)*100
			@users_weekly = Share.where(:date.gt => Time.now - 1.week, :campaign_id => @campaign.id).count
			share_ids = Share.where(:campaign_id => @campaign.id).map(&:_id)
			@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week, :share_id.in => share_ids)
			@redeems_weekly = Redeem.where(:date.gt => Time.now - 1.week, :campaign_id => @campaign.id).order_by([:date, :desc]).count
			@total_pinterest_clicks = @campaign.pinterest_clicks
			@total_twitter_clicks = @campaign.twitter_clicks
			@total_facebook_clicks = @campaign.facebook_clicks
			@total_tumblr_clicks = @campaign.tumblr_clicks
			@total_social_clicks = @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks
			@users_monthly = Share.where(:date.gt => Time.now - 1.month, :campaign_id => @campaign.id).count
			@trackings_monthly = Tracking.where(:date.gt => Time.now - 1.month, :share_id.in => share_ids)
			@redeems_monthly = Redeem.where(:date.gt => Time.now - 1.month, :campaign_id => @campaign.id).order_by([:date, :desc]).count
			@last_users = @campaign.users.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4
		end
	end

	def view_campaign_buddees
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		end
	end

	def view_campaign_redeems
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		end
	end

	def view_campaign_tasks
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			@total_completed_blog = @campaign.tasks.where(completed_blog: true).count
			@total_completed_facebook = @campaign.tasks.where(completed_facebook: true).count
			@total_completed_twitter = @campaign.tasks.where(completed_twitter: true).count
			@total_completed_custom1 = @campaign.custom_tasks_completed(0)
			@total_completed_custom2 = @campaign.custom_tasks_completed(1)
			@total_completed_custom3 = @campaign.custom_tasks_completed(2)
			@total_completed_custom4 = @campaign.custom_tasks_completed(3)
			@total_completed_custom5 = @campaign.custom_tasks_completed(4)
			@total_engagement_left_clicks = 0
			@total_engagement_left_uniques = 0
			@total_engagement_right_clicks = 0
			@total_engagement_right_uniques = 0
			@campaign.tasks.each do |t|
				@total_engagement_left_clicks += t.task_1_clicks
				@total_engagement_left_uniques += t.task_1_uniques
				@total_engagement_right_clicks += t.task_2_clicks
				@total_engagement_right_uniques += t.task_2_uniques
			end
			@engagement_left_clicks=[]
			@engagement_left_uniques=[]
			right_now = DateTime.now - 29.days
			for i in 0..29
				clicks = 0
				uniques = 0
				@campaign.tasks.each do |t|
					curr_task_clicks = t.task_clicks.where(:created_at.lte => right_now).where(:task_number => 1)
					curr_task_clicks.each do |tc|
						clicks += tc.views.to_i
						uniques += 1
					end
				end
				@engagement_left_clicks[i] = [i+1,clicks.to_i]
				@engagement_left_uniques[i] = [i+1,uniques.to_i]
				right_now += 24.hours
			end
			@engagement_right_clicks=[]
			@engagement_right_uniques=[]
			right_now = DateTime.now - 29.days
			for i in 0..29
				clicks = 0
				uniques = 0
				@campaign.tasks.each do |t|
					curr_task_clicks = t.task_clicks.where(:created_at.lte => right_now).where(:task_number => 2)
					curr_task_clicks.each do |tc|
						clicks += tc.views.to_i
						uniques += 1
					end
				end
				@engagement_right_clicks[i] = [i+1,clicks.to_i]
				@engagement_right_uniques[i] = [i+1,uniques.to_i]
				right_now += 24.hours
			end
		end
	end

	def all_redeems
		@brand = Brand.find(@current_brand.id)
	end

	def go_viral_page
		@brand = Brand.find(@current_brand.id)
	end

	def viral_campaign_picked
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		end
	end

	def viral_campaign_install_fb
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			if @brand.facebook_token.blank? || (!@brand.facebook_expires.nil? && @brand.facebook_expires <= DateTime.now)
				redirect_to "/brands/facebook-re-connect?_id=#{@campaign.id}"
			else
				@facebook = Koala::Facebook::API.new(@brand.facebook_token)
				begin
					@accounts = @facebook.get_connections("me", "accounts")
				rescue Koala::Facebook::APIError
					flash[:error] = "An error occurred while trying to communicate with your Facebook Account. To fix this, please <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn btn-mini btn-warning'>Reconnect With Facebook</a>"
					redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
				rescue Koala::Facebook::AuthenticationError
					flash[:error] = "An error occurred while trying to communicate with your Facebook Account. To fix this, please <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn btn-mini btn-warning'>Reconnect With Facebook</a>"
					redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
				rescue Koala::Facebook::ClientError
					flash[:error] = "An error occurred while trying to communicate with your Facebook Account. To fix this, please <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn btn-mini btn-warning'>Reconnect With Facebook</a>"
					redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
				end
			end
		end
	end

	def viral_campaign_fb_page_chosen
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to view could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			unless params[:pageid].nil? || params[:acctok].nil? || params[:pagename].nil?
				fb_page_id = params[:pageid]
				fb_page_token = params[:acctok]
				fb_page_name = URI.unescape(params[:pagename])
				fb_page_name.gsub!(/\+/, " ")
				@page_graph = Koala::Facebook::API.new(fb_page_token)
				@result = @page_graph.put_connections(fb_page_id, 'tabs', :app_id => "479922585431487")
				if @result==true
					@result = @page_graph.get_connection('me', 'tabs')
					@result.each do |tab|
						unless tab["application"].blank?
							if tab["application"]["id"] == "479922585431487"
								@tab_id = tab["id"]
								@tab_link = tab["link"]
								break
							end
						end
					end
					unless @tab_id.blank? || @tab_link.blank?
						@embed = @brand.embeds.where(fb_page_id: fb_page_id).first
						if @embed.nil?
							@brand.embeds.create!(campaign_link: @campaign.link, fb_page_id: fb_page_id, fb_page_name: fb_page_name, fb_tab_id: @tab_id)
						else
							@embed.campaign_link = @campaign.link
							@embed.save!
						end
						flash[:info] = "The Go Viral! Widget for this campaign has been installed to your Facebook page! Here is the link: <a href='#{@tab_link}' target='_blank'>#{@tab_link}</a>"
						redirect_to "/brands/dashboard"
					else
						@embed = @brand.embeds.where(fb_page_id: fb_page_id).first
						if @embed.nil?
							@brand.embeds.create!(campaign_link: @campaign.link, fb_page_id: fb_page_id, fb_page_name: fb_page_name, fb_tab_id: "#{fb_page_id}/tabs/app_479922585431487")
						else
							@embed.campaign_link = @campaign.link
							@embed.save!
						end
						flash[:info] = "The Go Viral! Widget for this campaign has been installed to your Facebook page! You can find it on your Facebook page."
						redirect_to "/brands/dashboard"
					end
				else
					flash[:error] = "An error occurred while trying to install the embed widget to your Facebook page. Please try again."
					redirect_to "/brands/dashboard"
				end
			else
				flash[:error] = "You must select a Facebook Page to install the Embed Widget on"
				redirect_to "/brands/campaigns/viral-install-fb?_id=#{@campaign.id}"
			end
		end
	end

	def facebook_reconnect
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to install to your Facebook Page could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			session[:brand_connect_with_fb] = @campaign.id
			redirect_to "/auth/facebook"
		end
	end
end
