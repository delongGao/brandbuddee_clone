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
		@total_linkedin_clicks = 0
		@total_google_plus_clicks = 0
		@total_facebook_likes = 0
		@total_twitter_follows = 0
		@brand.campaigns.each do |c|
			@total_pinterest_clicks += c.pinterest_clicks
			@total_twitter_clicks += c.twitter_clicks
			@total_facebook_clicks += c.facebook_clicks
			@total_tumblr_clicks += c.tumblr_clicks
			@total_linkedin_clicks += c.linkedin_clicks
			@total_google_plus_clicks += c.google_plus_clicks
			@total_facebook_likes += c.tasks.where(completed_facebook: true).count if c.task_facebook["use_it"]==true
			@total_twitter_follows += c.tasks.where(completed_twitter: true).count if c.task_twitter["use_it"]==true
			c.users.each do |u|
				@users_list << u
			end
		end
		@total_social_clicks = @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks + @total_linkedin_clicks + @total_google_plus_clicks
		@users_list = @users_list.uniq.last(5)
	end

	def view_edit_profile
		@brand = Brand.find(@current_brand.id)
	end

	def update_profile
		@brand = Brand.find(@current_brand.id)
		begin
			if !params[:brand][:remove_brand_logo].nil? && params[:brand][:remove_brand_logo] == "1"
				#@brand.remove_brand_logo!
				#@brand.brand_logo = nil
				@brand.remove_brand_logo = true
				@brand.save!(validate: false)
			end
			@brand.attributes = params[:brand]
			@brand.last_updated = DateTime.now
			if @brand.save
				if !session[:brand_profile_unfinished].nil? && session[:brand_profile_unfinished].to_s == "true"
					session[:brand_profile_unfinished] = nil
					BrandMailer.profile_completion(@brand, root_url).deliver
				end
				if cookies[:brand_tour].present? && cookies[:brand_tour].to_s == "true"
					redirect_to "/brands/dashboard"
				else
					flash[:info] = "Your Brand Profile has been updated!"
					redirect_to "/brands/profile"
				end
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
			@total_linkedin_clicks = @campaign.linkedin_clicks
			@total_google_plus_clicks = @campaign.google_plus_clicks
			@total_social_clicks = @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks + @total_linkedin_clicks + @total_google_plus_clicks
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
			@total_completed_email = @campaign.tasks.where(completed_email: true).count
			@total_completed_yelp = @campaign.tasks.where(completed_yelp: true).count
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
				begin
					@result = @page_graph.put_connections(fb_page_id, 'tabs', :app_id => "278238152312772")
					if @result==true
						@result = @page_graph.get_connection('me', 'tabs')
						@result.each do |tab|
							unless tab["application"].blank?
								if tab["application"]["id"] == "278238152312772"
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
								@brand.embeds.create!(campaign_link: @campaign.link, fb_page_id: fb_page_id, fb_page_name: fb_page_name, fb_tab_id: "#{fb_page_id}/tabs/app_278238152312772")
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
				rescue Koala::Facebook::APIError => exc
					if exc.message == "OAuthException: (#200) User does not have sufficient administrative permission for this action on this page"
						flash[:error] = "You do not have sufficient administrative permission to install a Facebook App to that Page. Please choose a different Facebook Page."
					else
						flash[:error] = "An error occured while trying to install the Go Viral! Widget to your Facebook Page. We have been notified. Please try again later."
						UserMailer.email_brice_error("Error at brands_controller#viral_campaign_fb_page_chosen. Message: #{exc.message}").deliver
					end
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
			redirect_to "/auth/facebook?state=brand_connect_with_fb_#{@campaign.id}"
		end
	end

	def viral_invite_email
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to install to your Facebook Page could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		end
	end

	def viral_invite_email_send
		@brand = Brand.find(@current_brand.id)
		unless params[:campaign_id].nil?
			@campaign = Campaign.find(params[:campaign_id])
			unless @campaign.nil? || @campaign.brand.id != @brand.id
				unless params[:to].blank?
					subject = "#{@brand.name} wants you to check out this free giveaway!"
					unless params[:message].blank?
						message = params[:message]
					else
						message = "Check out #{@brand.name} on brandbuddee.com!"
					end
					unless @brand.embeds.where(link:@campaign.link).first.nil?
						page_id = @brand.embeds.where(link:@campaign.link).first.fb_page_id
					else
						page_id = "171681306187771"
					end
					if UserMailer.email_white_label_invite(params[:to], subject, message, @brand, page_id).deliver
						flash[:success] = "Your email has been sent!"
						redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
					else
						flash[:error] = "An error occurred while trying to send your email. Please try again."
						redirect_to "/brands/campaigns/viral-invite-email?_id=#{@campaign.id}"
					end
				else
					flash[:error] = "You must fill out the field: To, when telling friends via email"
					redirect_to "/brands/campaigns/viral-invite-email?_id=#{@campaign.id}"
				end
			else
				flash[:error] = "An error occurred while trying to find the campaign you are trying to share. Please try again."
				redirect_to "/brands/dashboard"	
			end
		else
			flash[:error] = "An error occurred while trying to find the campaign you are trying to share. Please try again."
			redirect_to "/brands/dashboard"
		end
	end

	def viral_invite_facebook
		@brand = Brand.find(@current_brand.id)
		@campaign = @brand.campaigns.where(:_id => params[:_id]).first unless params[:_id].blank?
		if @campaign.nil?
			flash[:error] = "The campaign you are trying to install to your Facebook Page could not be found. Please choose a different one."
			redirect_to "/brands/dashboard"
		else
			unless @brand.facebook_token.blank? || @brand.facebook_expires.blank? || @brand.facebook_expires < Time.now
				begin
					@facebook ||= Koala::Facebook::API.new(@brand.facebook_token)
					@friendslist = @facebook.get_connection("me", "friends", {"limit" => "100"})
					unless @friendslist.blank?
						@friendslist = @facebook.get_page(params[:page]) unless params[:page].nil?
					else
						flash[:error] = "We could not find any friends in your friends list. If you believe this message is an error on our part, it could be because you have not yet connected your account with Facebook, or because the connection has expired. If so, <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>."
						redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
					end
				rescue Koala::Facebook::APIError => e
					flash[:error] = "An error occurred while trying to retrieve your list of Facebook Friends. This could be because you have not yet connected your account with Facebook, or because the connection has expired. Either way <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>. Here is the error: #{e.to_s}"
					redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
				end
			else
				flash[:error] = "Your brand account has not been connected with Facebook, or the connection has expired. Either way <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>"
				redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
			end
		end
	end

	def viral_invite_fb_search
		@brand = Brand.find(@current_brand.id)
		unless params[:campaign_id].nil?
			@campaign = Campaign.find(params[:campaign_id])
			unless @campaign.nil?
				unless @brand.facebook_token.blank? || @brand.facebook_expires.blank? || @brand.facebook_expires < Time.now
					begin
						@facebook ||= Koala::Facebook::API.new(@brand.facebook_token)
						@allfriends = @facebook.get_connection("me", "friends")
						unless @allfriends.blank?
							unless params[:query].blank?
								query_split = params[:query].split(" ")
								@friendslist = Array.new
								@allfriends.each do |friend|
									add_me = false
									name_split = friend["name"].split(" ")
									name_split.each do |n|
										query_split.each do |q|
											if n.downcase.start_with?(q.downcase) || n.downcase.end_with?(q.downcase)
												add_me = true
												break
											end
										end
									end
									unless add_me.nil? || add_me == false
										@friendslist << {"id" => friend["id"], "name" => friend["name"]}
									end
								end
							else
								flash[:error] = "You must enter a name when searching for a Facebook Friend. Please try again."
								redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
							end
						else
							flash[:error] = "We could not find any friends in your friends list. If you believe this message is an error on our part, it could be because you have not yet connected your account with Facebook, or because the connection has expired. If so, <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>."
							redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
						end
					rescue Koala::Facebook::APIError => e
						flash[:error] = "An error occurred while trying to retrieve your list of Facebook Friends. This could be because you have not yet connected your account with Facebook, or because the connection has expired. Either way <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>. Here is the error: #{e.to_s}"
						redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
					end
				else
					flash[:error] = "Your brand account has not been connected with Facebook, or the connection has expired. Either way <a href='/brands/facebook-re-connect?_id=#{@campaign.id}' class='btn-mini btn-warning'>Click Here to Reconnect with Facebook</a>"
					redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
				end
			else
				flash[:error] = "An error occurred while trying to find the campaign you are trying to share."
				redirect_to "/brands/dashboard"
			end
		else
			flash[:error] = "An error occurred while trying to find the campaign you are trying to share."
			redirect_to "/brands/dashboard"
		end
	end

	def start_brand_tour
		if cookies[:brand_tour].nil?
			cookies[:brand_tour] = {:value => true, :expires => Time.now + 1.month}
		end
		redirect_to "/brands/dashboard"
	end

	def end_brand_tour
		unless cookies[:brand_tour].nil? || cookies[:brand_tour].to_s != "true"
			cookies.delete(:brand_tour)
		end
		redirect_to "/brands/dashboard"
	end

	def sample_campaign_list
		@brand = current_brand
	end

	def sample_campaign_view
		@brand = current_brand
	end

	def sample_viral_embed
		@brand = current_brand
	end

	def sample_redeems_view
		@brand = current_brand
	end

	def sample_tasks_view
		@brand = current_brand
	end

	def update_fb_token_via_ajax
		if request.xhr?
			unless params[:token].nil? || params[:expires].nil?
				if current_brand
					@graph = Koala::Facebook::API.new(params[:token])
					begin
						profile = @graph.get_object("me")
						unless profile.nil? || profile["id"].nil?
							@brand = current_brand
							@brand.facebook_token = params[:token].to_s
							@brand.facebook_expires = DateTime.now + params[:expires].to_i.seconds
							if @brand.save
								render :text => "SUCCESS"
							else
								render :text => "ERROR"
							end
						else
							render :text => "ERROR"
						end
					rescue Koala::Facebook::APIError
						render :text => "ERROR"
					end
				else
					render :text => "ERROR"
				end
			else
				render :text => "ERROR"
			end
		else
			flash[:error] = "An error occurred. Please refresh this page and try again."
			redirect_to root_url
		end
	end
end
