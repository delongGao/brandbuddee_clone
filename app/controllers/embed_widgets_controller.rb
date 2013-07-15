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

	def facebook_index
		@continue = false
		if params[:signed_request].nil? 
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			@signed_request = params[:signed_request]
			@oauth = Koala::Facebook::OAuth.new(479922585431487, "6e313eda5412f9ac3023a17a99e80b31")
			@result = @oauth.parse_signed_request(@signed_request)
			unless @result["page"].nil? || @result["page"]["id"].nil? || @result["page"]["liked"].nil? || @result["page"]["admin"].nil?
				if @result["page"]["liked"]==true
					# @embed = Embed.where(fb_page_id: @result["page"]["id"].to_s).last
					# unless @embed.nil? || @embed.campaign_link.empty?
						# @campaign = Campaign.where(link: @embed.campaign_link).first
						@campaign = Campaign.where(link: "7938298")
						unless @campaign.nil?
							# if current_user
							# 	already_joined = false
							# 	current_user.campaigns.each do |c|
							# 		if c.id == @campaign.id
							# 			already_joined = true
							# 		end
							# 	end
							# 	if already_joined == true
							# 		redirect_to '/fb-joined-campaign'
							# 	else
									@continue = true
									@logged_in = false
									@total_page_views = 0
									@campaign.shares.each do |s|
										@total_page_views += s.cookie_unique_page_views
									end
								# end
							# elsif current_brand
							# 	session[:brand_id] = nil
							# 	@continue = true
							# 	@total_page_views = 0
							# 	@campaign.shares.each do |s|
							# 		@total_page_views += s.cookie_unique_page_views
							# 	end
							# else
							# 	@continue = true
							# 	@total_page_views = 0
							# 	@campaign.shares.each do |s|
							# 		@total_page_views += s.cookie_unique_page_views
							# 	end
							# end
						else
							@error = "The campaign associated with this Facebook Page could not be found."
						end
					# else
					# 	@error = "An error occured while trying to find the campaign associated with this Facebook Page."
					# end
				else
					@continue = true
				end
			else
				@error = "This App is not intended to be viewed on its own. To function properly, it should be viewed from a Facebook Page."
			end
		end
	end

	def facebook_signup
		if current_user || current_brand
			redirect_to "/fb-campaign-embed"
		else
			@user = User.new
		end
	end

	def facebook_create
		
	end

	def facebook_joined_camp
		
	end

end
