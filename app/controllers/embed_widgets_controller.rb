class EmbedWidgetsController < ApplicationController

	def index
		params_campaign = params[:campaign].downcase
		campaign = Campaign.where(:link => params_campaign).first
		if campaign.present?
			@campaign = campaign
		end
		if campaign.nil?
			render text: "An error occured while trying to find this campaign. Please try again later." # At some point, create a custom error page that will look good in an iframe...
		else
			@brand = @campaign.brand
			if @brand.nil?
				render text: "An error occured while trying to find the brand associated with this campaign. Please try again later."
			else
				@user = User.new
			end
		end
	end

	def create_user
		
	end

	def facebook_like_gate
		@continue = false
		if params[:signed_request].nil?
			if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
				@error = "UHOH!"
			else
				if params[:liked] == "true"
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					@continue = true
				end
			end
		else
			@signed_request = params[:signed_request]
			@oauth = Koala::Facebook::OAuth.new(479922585431487, "6e313eda5412f9ac3023a17a99e80b31")
			@result = @oauth.parse_signed_request(@signed_request)
			unless @result["page"].nil? || @result["page"]["id"].nil? || @result["page"]["liked"].nil? || @result["page"]["admin"].nil? # Else, It is being viewed from App Canvas Page
				if @result["page"]["liked"]==true
					redirect_to "/fb-campaign-embed?page_id=#{@result["page"]["id"]}&liked=#{@result["page"]["liked"]}&admin=#{@result["page"]["admin"]}"
				else
					@continue = true
				end
			else
				@error = "This App is not intended to be viewed on its own. To function properly, it should be viewed from a Facebook Page."
			end
		end
	end

	def facebook_index
		@continue = false
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			if params[:admin] == "true"
				redirect_to '/fb-embed-admin'
			else
				if params[:liked] == "true"
					# @embed = Embed.where(fb_page_id: params[:page_id].to_s).last
					# unless @embed.nil? || @embed.campaign_link.empty?
						# @campaign = Campaign.where(link: @embed.campaign_link).first
						@campaign = Campaign.where(link: "7938298").first
						unless @campaign.nil?
							if current_user
								already_joined = false
								current_user.campaigns.each do |c|
									if c.id == @campaign.id
										already_joined = true
									end
								end
								if already_joined == true
									redirect_to '/fb-joined-campaign'
								else
									@continue = true
									@logged_in = true
									@total_page_views = 0
									@campaign.shares.each do |s|
										@total_page_views += s.cookie_unique_page_views
									end
								end
							# elsif current_brand
							# 	session[:brand_id] = nil
							# 	@continue = true
							# 	@total_page_views = 0
							# 	@campaign.shares.each do |s|
							# 		@total_page_views += s.cookie_unique_page_views
							# 	end
							else
								@continue = true
								@total_page_views = 0
								@campaign.shares.each do |s|
									@total_page_views += s.cookie_unique_page_views
								end
							end
						else
							@error = "The campaign associated with this Facebook Page could not be found."
						end
					# else
					# 	@error = "An error occured while trying to find the campaign associated with this Facebook Page."
					# end
				else
					redirect_to "/fb-like-gate?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			end
		end
	end

	def facebook_signup
		if current_user
			redirect_to "/fb-campaign-embed"
		# elsif current_brand
		# 	session[:brand_id] = nil
		# 	@user = User.new
		else
			@user = User.new
		end
	end

	def facebook_create
		
	end

	def facebook_joined_camp
		@continue = false
		if params[:signed_request].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
			# BEGIN SHIT TO KILL LATER
				# @error = nil
				# @continue = true
				# @campaign = Campaign.where(link:"3664591").first
				# user = User.where(email:"server4001@gmail.com").first
				# @share = Share.where(campaign_id: @campaign.id, user_id: user.id).first
				# @total_pts = 10
			# END SHIT TO KILL LATER
		else
			@signed_request = params[:signed_request]
			@oauth = Koala::Facebook::OAuth.new(479922585431487, "6e313eda5412f9ac3023a17a99e80b31")
			@result = @oauth.parse_signed_request(@signed_request)
			unless @result["page"].nil? || @result["page"]["id"].nil? || @result["page"]["liked"].nil? || @result["page"]["admin"].nil?
				if @result["page"]["admin"] == true
					redirect_to '/fb-embed-admin'
				else
					if @result["page"]["liked"] == true
						if current_user
							# @embed = Embed.where(fb_page_id: @result["page"]["id"].to_s).last
							# unless @embed.nil? || @embed.campaign_link.empty?
								# @campaign = Campaign.where(link: @embed.campaign_link).first
								@campaign = Campaign.where(link: "7938298").first
								unless @campaign.nil?
									@share = Share.where(:campaign_id => @campaign.id, :user_id => current_user.id).first
									unless @share.nil?
										@continue = true
										task_update = @campaign.tasks.where(user_id: current_user.id).first
										if task_update.nil?
											@total_pts = @share.unique_page_views + @share.trackings.size
										else
											completed_task_points = task_update.completed_points
											engagement_1_points = task_update.task_1_uniques.to_i * @campaign.engagement_task_left_points.to_i
											engagement_2_points = task_update.task_2_uniques.to_i * @campaign.engagement_task_right_points.to_i
											@total_pts = @share.unique_page_views + @share.trackings.size + completed_task_points + engagement_1_points + engagement_2_points
										end
									else
										@error = "An error occured while attempting to connect the campaign with your buddee account. Please try again later."
									end
								else
									@error = "The campaign associated with this Facebook Page could not be found."
								end
							# else
							# 	@error = "An error occured while trying to find the campaign associated with this Facebook Page."
							# end
						else
							redirect_to '/fb-campaign-embed'
						end
					else
						redirect_to '/fb-like-gate'
					end
				end
			else
				@error = "This App is not intended to be viewed on its own. To function properly, it should be viewed from a Facebook Page."
			end
		end
	end

	def facebook_admin_page
		@continue = false
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			if params[:admin] == "true"
				# @embed = Embed.where(fb_page_id: params[:page_id].to_s).last
				# unless @embed.nil? || @embed.campaign_link.empty?
					# @campaign = Campaign.where(link: @embed.campaign_link).first
					@campaign = Campaign.where(link: "7938298").first
					unless @campaign.nil?
						@continue = true
						@total_page_views = 0
						@campaign.shares.each do |s|
							@total_page_views += s.cookie_unique_page_views
						end
					else
						@error = "The campaign associated with this Facebook Page could not be found."
					end
				# else
					# @error = "An error occured while trying to find the campaign associated with this Facebook Page."
				# end
			else
				redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

end
