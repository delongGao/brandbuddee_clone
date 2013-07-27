class EmbedWidgetsController < ApplicationController

	# def index
	# 	params_campaign = params[:campaign].downcase
	# 	campaign = Campaign.where(:link => params_campaign).first
	# 	if campaign.present?
	# 		@campaign = campaign
	# 	end
	# 	if campaign.nil?
	# 		render text: "An error occurred while trying to find this campaign. Please try again later." # At some point, create a custom error page that will look good in an iframe...
	# 	else
	# 		@brand = @campaign.brand
	# 		if @brand.nil?
	# 			render text: "An error occurred while trying to find the brand associated with this campaign. Please try again later."
	# 		else
	# 			@user = User.new
	# 		end
	# 	end
	# end

	# def create_user
		
	# end

	def facebook_like_gate
		@continue = false
		if params[:signed_request].nil?
			if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
				@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
			else
				if params[:liked] == "true"
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					@continue = true
					@page_id = params[:page_id]
					@liked = params[:liked]
					@admin = params[:admin]
				end
			end
		else
			@signed_request = params[:signed_request]
			@oauth = Koala::Facebook::OAuth.new(278238152312772, "fbf139910f26420742f3d88f3b25f9a9")
			@result = @oauth.parse_signed_request(@signed_request)
			unless @result["oauth_token"].nil?
				@graph = Koala::Facebook::API.new(@result["oauth_token"])
				@permissions = @graph.get_connection("me", "permissions")
				unless @permissions[0].nil?
					if @permissions[0]["installed"] == 1 && @permissions[0]["email"] == 1 && @permissions[0]["publish_actions"] == 1 && @permissions[0]["publish_stream"] == 1 && @permissions[0]["user_birthday"] == 1 && @permissions[0]["user_about_me"] == 1 && @permissions[0]["user_location"] == 1 && @permissions[0]["user_likes"] == 1 && @permissions[0]["user_education_history"] == 1 && @permissions[0]["user_website"] == 1 && @permissions[0]["read_friendlists"] == 1 && @permissions[0]["user_interests"] == 1 && @permissions[0]["user_hometown"] == 1 && @permissions[0]["user_status"] == 1 && @permissions[0]["manage_pages"] == 1
						unless @result["page"].nil? || @result["page"]["id"].nil? || @result["page"]["liked"].nil? || @result["page"]["admin"].nil?
							if @result["page"]["liked"]==true
								redirect_to "/fb-campaign-embed?page_id=#{@result["page"]["id"]}&liked=#{@result["page"]["liked"]}&admin=#{@result["page"]["admin"]}"
							else
								@continue = true
								@page_id = @result["page"]["id"]
								@liked = @result["page"]["liked"]
								@admin = @result["page"]["admin"]
							end
						else
							@error = "This App is not intended to be viewed on its own. To function properly, it should be viewed from a Facebook Page."
						end
					else
						@error = "redirect_to_permissions_oauth"
					end
				else
					@error = "redirect_to_permissions_oauth"
				end
			else
				@error = "redirect_to_permissions_oauth"
			end
		end
	end

	def facebook_index
		@continue = false
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			if params[:admin] == "true"
				redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			else
				if params[:liked] == "true"
					@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
					unless @embed.nil? || @embed.campaign_link.blank?
						@campaign = Campaign.where(link: @embed.campaign_link).first
						unless @campaign.nil?
							@left = @campaign.limit - @campaign.redeems.size
							if current_user
								already_joined = false
								current_user.campaigns.each do |c|
									if c.id == @campaign.id
										already_joined = true
									end
								end
								if already_joined == true
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									@continue = true
									@logged_in = true
									@total_page_views = 0
									@campaign.shares.each do |s|
										@total_page_views += s.cookie_unique_page_views
									end
								end
							elsif current_brand
								session[:brand_id] = nil
								@continue = true
								@total_page_views = 0
								@campaign.shares.each do |s|
									@total_page_views += s.cookie_unique_page_views
								end
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
					else
						@error = "An error occurred while trying to find the campaign associated with this Facebook Page."
					end
				else
					redirect_to "/fb-like-gate?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			end
		end
	end

	def facebook_signup
		@continue = false
		unless params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
			unless @embed.nil? || @embed.campaign_link.blank?
				@campaign = Campaign.where(link: @embed.campaign_link).first
				unless @campaign.nil?
					if current_user
						redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					elsif current_brand
						@continue = true
						session[:brand_id] = nil
						@user = User.new
					else
						@continue = true
						@user = User.new
					end
				else
					@error = "The campaign associated with this Facebook Page could not be found."
				end
			else
				@error = "An error occurred while trying to find the campaign associated with this Facebook Page."
			end
		else
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		end
	end

	def facebook_signup_fb_auth
		unless params[:campaign_id].nil? || params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			session[:fb_embed_widget_signup] = "#{params[:campaign_id]}|#{params[:page_id]}|#{params[:liked]}|#{params[:admin]}"
			redirect_to "/auth/facebook"
		else
			redirect_to "/fb-campaign-embed"
		end
	end

	def facebook_create
		unless params[:user].nil?
			@user = User.create(params[:user])
			if @user.save
				session[:user_id] = @user.id
				@campaign = Campaign.find(params[:campaign_id])
				unless @campaign.nil?
					@left = @campaign.limit - @campaign.redeems.size
					unless @left < 1 || @campaign.end_date < Time.now
						@campaign.user_ids << @user.id
		                share_link = Share.assign_link
		                @campaign.shares.create!(date: Time.now, link: share_link, user_id: @user.id, campaign_id: @campaign.id, url: @campaign.share_link)
		                @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: @user.id, campaign_id: @campaign.id)
		                if @campaign.save
		                  redirect_to "/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		                else
		                  redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		                end
		            else
		            	flash[:info] = "Your account has been created! Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
		            	redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		            end
				else
					flash[:error] = "We could not find the campaign associated with this Facebook Page. Please try again later."
					redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "You must fill out all the fields correctly."
				redirect_to "/fb-embed-signup?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		else
			flash[:error] = "You must fill out the entire form when creating an account. Please try again."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_email_signin
		unless params[:email].nil? || params[:password].nil? || params[:page_id].nil? || params[:liked].nil? || params[:admin].nil? || params[:campaign_id].nil?
			user = User.authenticate(params[:email], params[:password])
			if user
		        user.last_login = Time.now
		        if user.save
		        	session[:user_id] = user.id
		        	if params[:admin].to_s == "true" # User IS an admin of the Facebook Page
		        		if user.nickname.nil? || user.nickname.blank?
	        				redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
	        			else
	        				redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		                end
		        	else # User is NOT an admin of the Facebook Page
			        	@campaign = Campaign.find(params[:campaign_id])
			        	unless @campaign.nil?
			        		unless @campaign.already_has_user_share?(user)
			        			@left = @campaign.limit - @campaign.redeems.size
			        			unless @left < 1 || @campaign.end_date < Time.now
				        			@campaign.user_ids << user.id
					                share_link = Share.assign_link
					                @campaign.shares.create!(date: Time.now, link: share_link, user_id: user.id, campaign_id: @campaign.id, url: @campaign.share_link)
					                unless @campaign.already_has_user_task?(user)
					                  	@campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: user.id, campaign_id: @campaign.id)
					                  	if @campaign.save
					                    	if user.nickname.nil? || user.nickname.blank?
					                    		redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					                    	else
				        						redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				        					end
				        				else
				        					flash[:error] = "An error occurred while trying to add your buddee account to the campaign. Please try again."
				        					redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						                end
						            else
						            	if user.nickname.nil? || user.nickname.blank?
					        				redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					        			else
					        				redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						                end
				        			end
				        		else
				        			flash[:info] = "You are now logged in! Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
				        			redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				        		end
			        		else
			        			if user.nickname.nil? || user.nickname.blank?
			        				redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			        			else
			        				redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				                end
			        		end
			        	else
			        		flash[:error] = "We could not find the Campaign associated with this Facebook Page. Please try again later."
			        		redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			        	end
			        end # END User is NOT an admin of the Facebook Page
		        else
		        	flash[:error] = "An error occurred while trying to log you in. Please try again."
		        	redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		        end
		    else
		    	flash[:error] = "Invalid Email or Password. Please try again."
		    	if params[:admin].to_s == "true"
		    		redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		    	else
		    		redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
		    	end
		    end
		else
			flash[:error] = "When logging in, please make sure you fill out both the email and password fields."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_add_campaign
		unless params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
			unless @embed.nil? || @embed.campaign_link.blank?
				@campaign = Campaign.where(link: @embed.campaign_link).first
				unless @campaign.nil?
					if current_user
						unless @campaign.already_has_user_share?(user)
							@left = @campaign.limit - @campaign.redeems.size
							unless @left < 1 || @campaign.end_date < Time.now
								@campaign.user_ids << current_user.id
				                share_link = Share.assign_link
				                @campaign.shares.create!(date: Time.now, link: share_link, user_id: current_user.id, campaign_id: @campaign.id, url: @campaign.share_link)
				                unless @campaign.already_has_user_task?(user)
					                @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: current_user.id, campaign_id: @campaign.id)
					                if @campaign.save
					                	redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					                else
					                	flash[:error] = "An error occurred while trying to add your buddee account to the campaign. Please try again."
					                	redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					                end
					            else
					            	redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					            end
					        else
					        	flash[:error] = "Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
					        	redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					        end
			            else
			            	redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			            end
					else
						flash[:error] = "You must be logged in to join a campaign. Please try again after logging in."
						redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					flash[:error] = "An error occurred while trying to lookup the campaign associated with this Facebook Page. Please try again."
					redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "An error occurred while trying to lookup the campaign associated with this Facebook Page. Please try again."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		else
			flash[:error] = "An error occurred while trying to lookup the campaign associated with this Facebook Page. Please try again."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_joined_camp
		@continue = false
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			if params[:admin] == "true"
				redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			else
				if params[:liked] == "true"
					@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
					unless @embed.nil? || @embed.campaign_link.blank?
						@campaign = Campaign.where(link: @embed.campaign_link).first
						unless @campaign.nil?
							if current_user
								already_joined = false
								current_user.campaigns.each do |c|
									if c.id == @campaign.id
										already_joined = true
									end
								end
								if already_joined == true
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
										if @total_pts >= @share.campaign.points_required
											redeem_check = Redeem.where(:user_id => @share.user_id, :campaign_id => @share.campaign_id).first
											if redeem_check.nil?
												left = @share.campaign.limit - @share.campaign.redeems.size
												unless left <= 0 || @share.campaign.end_date < Time.now
													redeem_code = Redeem.assign_redeem_code()
													@redeem = Redeem.create!(date: Time.now, redeem_code: redeem_code, campaign_id: @share.campaign_id, user_id: @share.user_id)
													@redeem.save
													UserMailer.redeem_confirmation(@share.user_id, @redeem, @share.campaign, root_url).deliver
												end
											end
										end
										if Redeem.where(user_id: current_user.id, campaign_id: @campaign.id).first.nil?
											@gift_earned = false
										else
											@gift_earned = true
										end
									else
										@error = "An error occurred while attempting to connect the campaign with your buddee account. Please try again later."
									end
								else
									redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							flash[:error] = "An error occurred while trying to find the campaign associated with this Facebook Page. Please try again"
							redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					else
						flash[:error] = "An error occurred while trying to find the campaign associated with this Facebook Page. Please try again"
						redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					redirect_to "/fb-like-gate?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			end
		end
	end

	def facebook_admin_page
		@continue = false
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			@error = "This is the Go Viral! Facebook App built by brandbuddee. Become a brand, create a campaign, and watch it go viral by installing this app to your Facebook Page!"
		else
			if params[:admin] == "true"
				@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
				unless @embed.nil? || @embed.campaign_link.blank?
					@campaign = Campaign.where(link: @embed.campaign_link).first
					unless @campaign.nil?
						if current_user
							@logged_in = true
						else
							@logged_in = false
						end
						@continue = true
						@total_page_views = 0
						@campaign.shares.each do |s|
							@total_page_views += s.cookie_unique_page_views
						end
					else
						@error = "The campaign associated with this Facebook Page could not be found."
					end
				else
					@error = "An error occurred while trying to find the campaign associated with this Facebook Page."
				end
			else
				redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def facebook_error_page
		
	end

	def facebook_create_username
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			flash[:error] = "An error occurred while trying to create your account. Please refresh your page and try again."
			redirect_to "/fb-error-page"
		else
			if current_user
				unless current_user.nickname.nil? || current_user.nickname.blank?
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					@user = User.find(current_user.id)
				end
			elsif current_brand
				session[:brand_id] = nil
				flash[:info] = "You cannot create a buddee account while logged in as a brand. Please try again."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			else
				flash[:error] = "You must be logged in as a buddee to change or create your username. Please try again."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def facebook_update_username
		if current_user
			unless params[:user].nil?
				@user = User.find(current_user.id)
				user_nickname_before = params[:user][:nickname].downcase
				if user_nickname_before.match(/^[a-z0-9_]+$/)
					check_exist = User.first(conditions: {nickname: /^#{user_nickname_before}$/i}) # Case Insensitive
					if check_exist.nil? # Username NOT taken
						@user.nickname = user_nickname_before
						if @user.save
							if params[:admin].to_s == "true"
								redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							else
								@embed = Embed.where(fb_page_id: params[:page_id].to_s).last
								unless @embed.nil? || @embed.campaign_link.blank?
									@campaign = Campaign.where(link: @embed.campaign_link).first
									unless @campaign.nil?
										@left = @campaign.limit - @campaign.redeems.size
										unless @left < 1 || @campaign.end_date < Time.now
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:info] = "Your username has been updated! Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
											redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										flash[:error] = "An error occurred while trying to find the campaign associated with this Facebook Page. Please try again."
										redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									flash[:error] = "An error occurred while trying to find the campaign associated with this Facebook Page. Please try again."
									redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							end
						else
							flash[:error] = "An error occurred while trying to update your username. Please try again later."
							redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					else # Username IS taken
						flash[:error] = "That username has already been taken. Please choose another."
						redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					flash[:error] = "Invalid username. Lowercase letters, numbers, and underscores only. No spaces."
					redirect_to "/fb-create-username?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "You must choose a username before performing that action. Please try again."
				redirect_to "/fb-error-page"
			end

		else
			flash[:error] = "You must be logged in as a buddee to change or create your username. Please try again."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_wall_post
		unless params[:personal_message].blank?
			if current_user
				unless current_user.oauth_token.blank?
					begin
						facebook_graph = Koala::Facebook::GraphAPI.new(current_user.oauth_token)
						object_from_koala = facebook_graph.put_wall_post(params[:personal_message], {
							"name" => params[:name],
							"link" => params[:link],
							"caption" => params[:caption],
							"description" => params[:description],
							"picture" => params[:picture]
						})
						flash[:success] = "You have successfully posted to your Facebook Wall!"
						if params[:admin].to_s == "true"
							redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					rescue Koala::Facebook::APIError => exc
						if exc.message == "KoalaMissingAccessToken: Write operations require an access token"
							flash[:error] = "Posting to your Facebook Wall requires permissions that you have not given the brandbuddee Facebook App access to. Please <a href='/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}' class='btn btn-info btn-mini'>Connect With Facebook</a>"
							if params[:admin].to_s == "true"
								redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							else
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						elsif exc.message == "OAuthException: Error validating access token: The session has been invalidated because the user has changed the password."
							flash[:error] = "Your connection with Facebook has expired. Please <a href='/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}' class='btn btn-info btn-mini'>Connect With Facebook</a>"
							if params[:admin].to_s == "true"
								redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							else
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						elsif exc.message == "OAuthException: Error validating access token: Session does not match current stored session. This may be because the user changed the password since the time the session was created or Facebook has changed the session for security reasons."
							flash[:error] = "Your connection with Facebook has expired. Please <a href='/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}' class='btn btn-info btn-mini'>Connect With Facebook</a>"
							if params[:admin].to_s == "true"
								redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							else
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							flash[:error] = "An error occurred while trying to post to your Facebook Wall. Please try again later."
							redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					end
				else
					redirect_to "/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				if params[:admin].to_s == "true"
					redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			end
		else
			flash[:error] = "When posting to your Facebook Wall, please make sure you fill out all the fields."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_reauthenticate
		unless params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			if current_user
				session[:fb_embed_email_connect] = "#{params[:page_id]}|#{params[:liked]}|#{params[:admin]}"
				redirect_to "/auth/facebook"
			else
				if params[:admin].to_s == "true"
					redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			end
		else
			flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again later."
			redirect_to "/fb-error-page"
		end
	end

	def invite_facebook_list
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			flash[:error] = "An error occurred while trying to access your Facebook Friends list. Please try again."
			redirect_to "/fb-error-page"
		else
			if current_user
				if params[:admin].to_s == "true"
					unless current_user.oauth_token.nil?
						@friendslist = current_user.get_friends
						unless @friendslist.nil? || @friendslist.class == String
							@friendslist = params[:page] ? current_user.facebook.get_page(params[:page]) : current_user.facebook.get_connections("me", "friends", {"limit" => "100"})
						else
							flash[:error] = "An error occurred while trying to get a list of your Facebook Friends. Please reconnect your brandbuddee account with Facebook by <a href='/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}' class='btn btn-mini btn-info'>Clicking Here</a>"
							redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					else
						redirect_to "/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "Your must be logged in as a buddee to perform that action."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def invite_facebook_search
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			flash[:error] = "An error occurred while trying to access your Facebook Friends list. Please try again."
			redirect_to "/fb-error-page"
		else
			if current_user
				if params[:admin].to_s == "true"
					unless current_user.oauth_token.nil?
						@allfriends = current_user.get_friends
						unless @allfriends.nil? || @allfriends.class == String
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
								redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							flash[:error] = "An error occurred while trying to get a list of your Facebook Friends. Please reconnect your brandbuddee account with Facebook by <a href='/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}' class='btn btn-mini btn-info'>Clicking Here</a>"
							redirect_to "/fb-embed-admin?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					else
						redirect_to "/fb-connect-with-fb?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "Your must be logged in as a buddee to perform that action."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def invite_email_form
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			flash[:error] = "An error occurred while trying to find the Campaign associated with this Facebook Page. Please try again."
			redirect_to "/fb-error-page"
		else
			if current_user
				unless params[:admin].to_s == "true"
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "Your must be logged in as a buddee to perform that action."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def invite_email_send
		if params[:page_id].nil? || params[:liked].nil? || params[:admin].nil?
			flash[:error] = "An error occurred while trying to find the Campaign associated with this Facebook Page. Please try again."
			redirect_to "/fb-error-page"
		else
			if current_user
				if params[:admin].to_s == "true"
					unless params[:to].blank? || params[:message].nil?
						unless current_user.first_name.blank? || current_user.last_name.blank?
							subject = "Your friend #{current_user.first_name} #{current_user.last_name} says join brandbuddee"
						else
							subject = "Your friend says join brandbuddee"
						end
						unless params[:message].blank?
							message = params[:message]
						else
							message = "Hey, check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards."
						end
						if UserMailer.email_invite(params[:to], subject, message).deliver
							flash[:success] = "Your email has been sent!"
						else
							flash[:error] = "An error occurred while trying to send your email. Please try again."
						end
						redirect_to "/fb-invite-email-form?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					else
						flash[:error] = "You must fill out all fields in the form. Please try again."
						redirect_to "/fb-invite-email-form?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
					end
				else
					redirect_to "/fb-campaign-embed?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				end
			else
				flash[:error] = "Your must be logged in as a buddee to perform that action."
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		end
	end

	def facebook_task_complete
		unless params[:page_id].nil? || params[:liked].nil? || params[:admin].nil? || params[:task].nil? || params[:campaign_link].nil?
			if current_user
				params_campaign = params[:campaign_link].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					flash[:error] = "An error occurred while trying to find the campaign associated with this campaign. Please try again."
					redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					if params[:task].to_s == "blog"
						unless @campaign.task_blog_post["points"].nil?
							if !params[:txtBlogAddress].nil? && !params[:txtBlogAddress].empty?
								@task = @campaign.tasks.where(user_id: current_user.id).first
								unless @task.completed_blog == true
									@task.completed_blog = true
									@task.completed_points += @campaign.task_blog_post["points"].to_i
									@task.blog_post_url = params[:txtBlogAddress]
									@task.save
									flash[:success] = "You Have Completed the Blog Post Task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "You need to fill out the Blog Post Web Address"
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "yelp"
						unless @campaign.task_yelp["points"].nil?
							if !params[:txtYelpAddress].nil? && !params[:txtYelpAddress].empty?
								@task = @campaign.tasks.where(user_id: current_user.id).first
								unless @task.completed_yelp == true
									@task.completed_yelp = true
									@task.completed_points += @campaign.task_yelp["points"].to_i
									@task.yelp_review = params[:txtYelpAddress]
									@task.save
									flash[:success] = "You Have Completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "You need to fill out the Web Address"
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "facebook"
						unless @campaign.task_facebook["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if current_user.follows.where(brand_name: @campaign.brand.name, provider: "facebook").first.nil? && current_user.follows.where(provider: "facebook", link: @campaign.task_facebook["link"]).first.nil?
								unless @task.completed_facebook == true
									@task.completed_facebook = true
									@task.completed_points += @campaign.task_facebook["points"].to_i
									current_user.follows.create!(brand_name: @campaign.brand.name, provider: "facebook", link: @campaign.task_facebook["link"])
									@task.save
									flash[:success] = "You have completed the Facebook like task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "You are already following the brand on Facebook!"
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "twitter"
						unless @campaign.task_twitter["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if current_user.follows.where(brand_name: @campaign.brand.name, provider: "twitter").first.nil? && current_user.follows.where(provider: "twitter", link: @campaign.task_twitter["link"]).first.nil?
								unless @task.completed_twitter == true
									@task.completed_twitter = true
									@task.completed_points += @campaign.task_twitter["points"].to_i
									current_user.follows.create!(brand_name: @campaign.brand.name, provider: "twitter", link: @campaign.task_twitter["link"])
									@task.save
									flash[:success] = "You have completed the Twitter follow task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "You are already following the brand on Twitter!"
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "custom"
						if !params[:custom_num].nil? && !params[:custom_num].empty?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							case params[:custom_num]
							when "1"
								unless @campaign.task_custom_1["points"].nil?
									unless @task.completed_custom[0] == true
										@task.completed_custom[0] = true
										@task.completed_points += @campaign.task_custom_1["points"].to_i
										@task.save
										flash[:success] = "You have completed the task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									else
										flash[:error] = "You have already completed this task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							when "2"
								unless @campaign.task_custom_2["points"].nil?
									unless @task.completed_custom[1] == true
										@task.completed_custom[1] = true
										@task.completed_points += @campaign.task_custom_2["points"].to_i
										@task.save
										flash[:success] = "You have completed the task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									else
										flash[:error] = "You have already completed this task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							when "3"
								unless @campaign.task_custom_3["points"].nil?
									unless @task.completed_custom[2] == true
										@task.completed_custom[2] = true
										@task.completed_points += @campaign.task_custom_3["points"].to_i
										@task.save
										flash[:success] = "You have completed the task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									else
										flash[:error] = "You have already completed this task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							when "4"
								unless @campaign.task_custom_4["points"].nil?
									unless @task.completed_custom[3] == true
										@task.completed_custom[3] = true
										@task.completed_points += @campaign.task_custom_4["points"].to_i
										@task.save
										flash[:success] = "You have completed the task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									else
										flash[:error] = "You have already completed this task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							when "5"
								unless @campaign.task_custom_5["points"].nil?
									unless @task.completed_custom[4] == true
										@task.completed_custom[4] = true
										@task.completed_points += @campaign.task_custom_5["points"].to_i
										@task.save
										flash[:success] = "You have completed the task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									else
										flash[:error] = "You have already completed this task!"
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "An error occurred while trying to complete the task. Please try again"
								redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							flash[:error] = "An error occurred while trying to complete the task. Please try again"
							redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					end
				end
			else
				flash[:error] = "You must be logged in to complete a task!"
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		else
			flash[:error] = "An error occurred while trying to complete the task. Please try again."
			redirect_to "/fb-error-page"
		end
	end

	def facebook_task_undo
		unless params[:page_id].nil? || params[:liked].nil? || params[:admin].nil? || params[:task].nil? || params[:campaign_link].nil?
			if current_user
				params_campaign = params[:campaign_link].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					flash[:error] = "An error occurred while trying to find the campaign associated with this campaign. Please try again."
					redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
				else
					if params[:task].to_s == "blog"
						unless @campaign.task_blog_post["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
								if @task.completed_blog == true
									@task.completed_blog = false
									@task.completed_points -= @campaign.task_blog_post["points"].to_i
									@task.blog_post_url = nil
									@task.save
									flash[:info] = "You have undone the completion of the blog post task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have not yet completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "yelp"
						unless @campaign.task_yelp["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
								if @task.completed_yelp == true
									@task.completed_yelp = false
									@task.completed_points -= @campaign.task_yelp["points"].to_i
									@task.yelp_review = nil
									@task.save
									flash[:info] = "You have undone the completion of this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have not yet completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "facebook"
						unless @campaign.task_facebook["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
								unless @task.completed_facebook == false
									@task.completed_facebook = false
									@task.completed_points -= @campaign.task_facebook["points"].to_i
									t = current_user.follows.where(brand_name: @campaign.brand.name, provider: "facebook", link: @campaign.task_facebook["link"]).first
									unless t.nil?
										t.destroy
									end
									@task.save
									flash[:info] = "You have undone the completion of the Facebook like task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have not yet completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "twitter"
						unless @campaign.task_twitter["points"].nil?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
								unless @task.completed_twitter == false
									@task.completed_twitter = false
									@task.completed_points -= @campaign.task_twitter["points"].to_i
									t = current_user.follows.where(brand_name: @campaign.brand.name, provider: "twitter", link: @campaign.task_twitter["link"]).first
									unless t.nil?
										t.destroy
									end
									@task.save
									flash[:info] = "You have undone the completion of the Twitter follow task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								else
									flash[:error] = "You have not yet completed this task!"
									redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					elsif params[:task].to_s == "custom"
						if !params[:custom_num].nil? && !params[:custom_num].empty?
							@task = @campaign.tasks.where(user_id: current_user.id).first
							if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
								case params[:custom_num]
								when "1"
									unless @campaign.task_custom_1["points"].nil?
										unless @task.completed_custom[0] == false
											@task.completed_custom[0] = false
											@task.completed_points -= @campaign.task_custom_1["points"].to_i
											@task.save
											flash[:info] = "You have undone the task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:error] = "You have not yet completed this task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								when "2"
									unless @campaign.task_custom_2["points"].nil?
										unless @task.completed_custom[1] == false
											@task.completed_custom[1] = false
											@task.completed_points -= @campaign.task_custom_2["points"].to_i
											@task.save
											flash[:info] = "You have undone the task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:error] = "You have not yet completed this task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								when "3"
									unless @campaign.task_custom_3["points"].nil?
										unless @task.completed_custom[2] == false
											@task.completed_custom[2] = false
											@task.completed_points -= @campaign.task_custom_3["points"].to_i
											@task.save
											flash[:info] = "You have undone the task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:error] = "You have not yet completed this task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								when "4"
									unless @campaign.task_custom_4["points"].nil?
										unless @task.completed_custom[3] == false
											@task.completed_custom[3] = false
											@task.completed_points -= @campaign.task_custom_4["points"].to_i
											@task.save
											flash[:info] = "You have undone the task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:error] = "You have not yet completed this task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								when "5"
									unless @campaign.task_custom_5["points"].nil?
										unless @task.completed_custom[4] == false
											@task.completed_custom[4] = false
											@task.completed_points -= @campaign.task_custom_5["points"].to_i
											@task.save
											flash[:info] = "You have undone the task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										else
											flash[:error] = "You have not yet completed this task!"
											redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
										end
									else
										redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
									end
								else
									flash[:error] = "An error occurred while trying to complete the task. Please try again"
									redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
								end
							else
								flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
								redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
							end
						else
							redirect_to "/fb-joined-campaign?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
						end
					end
				end
			else
				flash[:error] = "You must be logged in to complete a task!"
				redirect_to "/fb-error-page?page_id=#{params[:page_id]}&liked=#{params[:liked]}&admin=#{params[:admin]}"
			end
		else
			flash[:error] = "An error occurred while trying to complete the task. Please try again."
			redirect_to "/fb-error-page"
		end
	end

end
