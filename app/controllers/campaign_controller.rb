class CampaignController < ApplicationController

	def index
		params_campaign = params[:campaign].downcase
		campaign = Campaign.where(:link => params_campaign).first
		#campaign_array = Campaign.where(:link => params_campaign)
		#@campaigns_else = Campaign.all(:limit => 4).order_by([:date, :desc])
		if campaign.present?
		  @campaign = campaign
		  @campaigns_else = Campaign.where(:status => "active").excludes(left: false).excludes(id: campaign.id).order_by([:date, :desc]).limit(4)
		  # @gallery = user.images.order_by([:date, :desc])
		  # @images = Image.all.order_by([:date, :desc])
		end
		if campaign.nil?
		  redirect_to root_url
		else
			unless @campaign.nil?
				unless current_user.nil?
					the_share = Share.where(:campaign_id => @campaign.id, :user_id => current_user.id).first
					unless the_share.nil? #User has not yet joined the campaign
						task_update = @campaign.tasks.where(user_id: current_user.id).first
						if task_update.nil?
							@completed_task_points = 0
							@engagement_1_points = 0
							@engagement_2_points = 0
						else
							@completed_task_points = task_update.completed_points
							@engagement_1_points = task_update.task_1_uniques.to_i * @campaign.engagement_task_left_points.to_i
							@engagement_2_points = task_update.task_2_uniques.to_i * @campaign.engagement_task_right_points.to_i
						end
						share_update = Share.find(the_share.id)
						user_share = share_update.user_id
						official_pts = share_update.unique_page_views + share_update.trackings.size + @completed_task_points + @engagement_1_points + @engagement_2_points
						if official_pts >= share_update.campaign.points_required
							redeem_check = Redeem.where(:user_id => user_share, :campaign_id => share_update.campaign_id).first
							if redeem_check.nil?
								left = share_update.campaign.limit - share_update.campaign.redeems.size
								unless left <= 0 || share_update.campaign.end_date < Time.now
									redeem_code = Redeem.assign_redeem_code()
									@redeem = Redeem.create!(date: Time.now, redeem_code: redeem_code, campaign_id: share_update.campaign_id, user_id: share_update.user_id )
									@redeem.save
									UserMailer.redeem_confirmation(user_share, @redeem, share_update.campaign, root_url).deliver
								end # unless left <= 0 || share_update.campaign.end_date < Time.now
							end # if redeem_check.nil?
						end # if official_pts >= share_update.campaign.points_required
					end # unless the_share.nil?
				end # unless current_user.nil?
			else
				redirect_to root_url
			end # unless/else @campaign.nil?
		end # If/else campaign.nil?
	end

	def activate_campaign
		@campaign = Campaign.find(params[:_c])
		unless @campaign.already_has_user_share?(current_user)
			@campaign.user_ids << current_user.id
			share_link = Share.assign_link
			@campaign.shares.create!(date: Time.now, link: share_link, user_id: current_user.id, campaign_id: @campaign.id, url: @campaign.share_link )
			#@campaign.shares.user_id = current_user.id
			#@campaign.shares.campaign_id = @campaign.id
			unless @campaign.already_has_user_task?(current_user)
				@campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: current_user.id, campaign_id: @campaign.id)

				url = root_url + "campaign/" + @campaign.link
				if @campaign.save
	      			flash[:notice] = "Campaign Activated"
	      			redirect_to url
	    		else
	      			flash[:notice] = "Uh oh"
	      			redirect_to url
	    		end
	    	else
	    		flash[:notice] = "You have already activated this campaign!"
	    		redirect_to "#{root_url}campaign/#{@campaign.link}"
	    	end
	    else
	    	flash[:notice] = "You have already activated this campaign!"
	    	redirect_to "#{root_url}campaign/#{@campaign.link}"
	    end
	end

	def share
		share = Share.where(:link => params[:share]).first
		if share.present?
			@task = Task.where(user_id: share.user_id, campaign_id: share.campaign_id).first
			unless @task.nil?
				@completed_task_points = @task.completed_points
				@engagement_1_points = @task.task_1_uniques.to_i * @task.campaign.engagement_task_left_points.to_i
				@engagement_2_points = @task.task_2_uniques.to_i * @task.campaign.engagement_task_right_points.to_i
			else
				@completed_task_points = 0
				@engagement_1_points = 0
				@engagement_2_points = 0
			end
			Share.page_view(share.id)

			#validates tracking based on client cookies
			c = cookies[share.id]
			if c == share.id
			elsif c.nil?
			  cookies[share.id] = share.id
			  Share.unique_page_view(share.id)
			end

			#validates tracking via unique IP addresses
			@ip_address = request.remote_ip
			if Tracking.validates_ip_uniqueness(@ip_address, share)
			  tracking = Tracking.where(:ip_address => @ip_address, :share_id => share.id).first
			  Tracking.view(tracking.id)
			else
			  Share.unique_page_view(share.id)
			  share.trackings.create!(date: Time.now, ip_address: @ip_address)
			end


			share_update = Share.find(share.id)
			user_share = share_update.user_id
			official_pts = share_update.unique_page_views + share_update.trackings.size + @completed_task_points + @engagement_1_points + @engagement_2_points
			if official_pts >= share_update.campaign.points_required
				redeem_check = Redeem.where(:user_id => user_share, :campaign_id => share_update.campaign_id).first
				if redeem_check.nil?
					left = share_update.campaign.limit - share_update.campaign.redeems.size
					unless left <= 0 || share_update.campaign.end_date < Time.now
						redeem_code = Redeem.assign_redeem_code()
						@redeem = Redeem.create!(date: Time.now, redeem_code: redeem_code, campaign_id: share_update.campaign_id, user_id: share_update.user_id )
						@redeem.save
						UserMailer.redeem_confirmation(user_share, @redeem, share_update.campaign, root_url).deliver
					end
				end
			end

			#redirect to share link
			@share = share
			@share_link = share.url
			@share_href = Share.get_host_without_www(share.url)

			if @share_href == 'facebook.com'
				redirect_to @share_link
			end

			#redirect_to share_link
		end
		if share.nil?
		  redirect_to root_url
		end
	end

	def facebook_wall_post
		if current_user
			unless params[:personal_message].blank?
				unless current_user.provider == "twitter"
					unless current_user.oauth_token.blank?
						begin
							# facebook_graph = Koala::Facebook::GraphAPI.new(current_user.oauth_token)
							facebook_graph = Koala::Facebook::API.new(current_user.oauth_token)
							object_from_koala = facebook_graph.put_wall_post(params[:personal_message], {
								"name" => params[:name],
								"link" => params[:link],
								"caption" => params[:caption],
								"description" => params[:description],
								"picture" => params[:picture]
							})
							@campaign = Campaign.where(link: params[:campaign_link]).first
							unless @campaign.nil?
								@campaign.facebook_clicks += 1
								@campaign.save(validate: false)
							end
							flash[:notice] = "Awesome! You've posted to your wall!"
							redirect_to "#{root_url}campaign/#{params[:campaign_link]}"
						rescue Koala::Facebook::APIError => exc
							flash[:error] = "An error occurred while trying to post to your Facebook Wall. Please <a href='/auth/facebook' class='btn btn-mini btn-warning'>Reconnect With Facebook</a> and try again. If messages that say \"brandbuddee would like to...\" occur, make sure you enable these permissions."
							redirect_to "#{root_url}campaign/#{params[:campaign_link]}"
						end
					else
						flash[:error] = "Before posting to your wall, you must first <a href='/auth/facebook' class='btn btn-mini btn-warning'>connect your account with Facebook</a>"
						redirect_to "#{root_url}campaign/#{params[:campaign_link]}"
					end
				else
					flash[:error] = "Because your account is uses Twitter to login, you cannot post to a facebook wall. You can either use the Post to Twitter button on this page, or <a href='/auth/facebook' class='btn btn-mini btn-warning'>switch to a Facebook Login account</a>"
					redirect_to "#{root_url}campaign/#{params[:campaign_link]}"
				end
			else
				flash[:error] = "Please enter a personal message"
				redirect_to "#{root_url}campaign/#{params[:campaign_link]}"
			end
		end
	end

	def resend_redeem_confirmation_email
		@redeem = Redeem.find(params[:_id])
		#@share = Share.where(:user_id => @redeem.user_id, :campaign_id => @redeem.campaign_id)
		@campaign = Campaign.find(@redeem.campaign_id)
		UserMailer.redeem_confirmation(@redeem.user_id, @redeem, @campaign, root_url).deliver

		flash[:notice] = "Redemption Email Resent"
		redirect_to(:controller => 'users', :action => 'show')
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

	def complete_blog_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_blog_post["points"].nil?
					if !params[:txtBlogAddress].nil? && !params[:txtBlogAddress].empty?
						if str_is_valid_url(params[:txtBlogAddress])
							@task = @campaign.tasks.where(user_id: current_user.id).first
							unless @task.nil?
								unless @task.completed_blog == true
									@task.completed_blog = true
									@task.completed_points += @campaign.task_blog_post["points"].to_i
									@task.blog_post_url = params[:txtBlogAddress]
									if @task.save
										flash[:notice] = "You have completed the blog post task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_blog_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_blog_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
								flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "You did not enter a valid URL for the Blog Post Web Address. It must start with http:// or https://."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						flash[:error] = "You need to fill out the Blog Post Web Address"
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def undo_blog_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_blog_post["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
							if @task.completed_blog == true
								@task.completed_blog = false
								@task.completed_points -= @campaign.task_blog_post["points"].to_i
								@task.blog_post_url = nil
								if @task.save
									flash[:notice] = "You have undone the completion of the blog post task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_blog_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
									flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have not yet completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_blog_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def complete_yelp_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_yelp["points"].nil?
					if !params[:txtYelpAddress].nil? && !params[:txtYelpAddress].empty?
						if str_is_valid_url(params[:txtYelpAddress])
							@task = @campaign.tasks.where(user_id: current_user.id).first
							unless @task.nil?
								unless @task.completed_yelp == true
									@task.completed_yelp = true
									@task.completed_points += @campaign.task_yelp["points"].to_i
									@task.yelp_review = params[:txtYelpAddress]
									if @task.save
										flash[:notice] = "You have completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										flash[:error] = "An error occurred while trying to save. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to find your information. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "You must enter a valid URL that starts with http:// or https://."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						flash[:error] = "You need to fill out the URL."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def undo_yelp_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_yelp["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
							if @task.completed_yelp == true
								@task.completed_yelp = false
								@task.completed_points -= @campaign.task_yelp["points"].to_i
								@task.yelp_review = nil
								if @task.save
									flash[:notice] = "You have undone the completion of this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									flash[:error] = "An error occurred while trying to save. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have not yet completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						flash[:error] = "An error occurred while trying to find your information. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def complete_facebook_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_facebook["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if current_user.follows.where(brand_name: @campaign.brand.name, provider: "facebook").first.nil? && current_user.follows.where(provider: "facebook", link: @campaign.task_facebook["link"]).first.nil?
							unless @task.completed_facebook == true
								@task.completed_facebook = true
								@task.completed_points += @campaign.task_facebook["points"].to_i
								current_user.follows.create!(brand_name: @campaign.brand.name, provider: "facebook", link: @campaign.task_facebook["link"])
								if @task.save
									flash[:notice] = "You have completed the Facebook like task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_facebook_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
									flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have already completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "You are already following the brand on Facebook!"
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_facebook_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def undo_facebook_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_facebook["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
							unless @task.completed_facebook == false
								@task.completed_facebook = false
								@task.completed_points -= @campaign.task_facebook["points"].to_i
								t = current_user.follows.where(brand_name: @campaign.brand.name, provider: "facebook", link: @campaign.task_facebook["link"]).first
								unless t.nil?
									t.destroy
								end
								if @task.save
									flash[:notice] = "You have undone the completion of the Facebook like task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_facebook_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
									flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have not yet completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_facebook_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def complete_twitter_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_twitter["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if current_user.follows.where(brand_name: @campaign.brand.name, provider: "twitter").first.nil? && current_user.follows.where(provider: "twitter", link: @campaign.task_twitter["link"]).first.nil?
							unless @task.completed_twitter == true
								@task.completed_twitter = true
								@task.completed_points += @campaign.task_twitter["points"].to_i
								current_user.follows.create!(brand_name: @campaign.brand.name, provider: "twitter", link: @campaign.task_twitter["link"])
								if @task.save
									flash[:notice] = "You have completed the Twitter follow task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_twitter_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
									flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have already completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "You are already following the brand on Twitter!"
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_twitter_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def undo_twitter_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				unless @campaign.task_twitter["points"].nil?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
							unless @task.completed_twitter == false
								@task.completed_twitter = false
								@task.completed_points -= @campaign.task_twitter["points"].to_i
								t = current_user.follows.where(brand_name: @campaign.brand.name, provider: "twitter", link: @campaign.task_twitter["link"]).first
								unless t.nil?
									t.destroy
								end
								if @task.save
									flash[:notice] = "You have undone the completion of the Twitter follow task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								else
									UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_twitter_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
									flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "You have not yet completed this task!"
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_twitter_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					redirect_to root_url
				end
			end
		else
			redirect_to root_url
		end
	end

	def complete_custom_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				if !params[:custom_num].nil? && !params[:custom_num].empty?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						case params[:custom_num]
						when "1"
							unless @campaign.task_custom_1["points"].nil?
								unless @task.completed_custom[0] == true
									@task.completed_custom[0] = true
									@task.completed_points += @campaign.task_custom_1["points"].to_i
									if @task.save
										flash[:notice] = "You have completed the task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						when "2"
							unless @campaign.task_custom_2["points"].nil?
								unless @task.completed_custom[1] == true
									@task.completed_custom[1] = true
									@task.completed_points += @campaign.task_custom_2["points"].to_i
									if @task.save
										flash[:notice] = "You have completed the task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						when "3"
							unless @campaign.task_custom_3["points"].nil?
								unless @task.completed_custom[2] == true
									@task.completed_custom[2] = true
									@task.completed_points += @campaign.task_custom_3["points"].to_i
									if @task.save
										flash[:notice] = "You have completed the task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						when "4"
							unless @campaign.task_custom_4["points"].nil?
								unless @task.completed_custom[3] == true
									@task.completed_custom[3] = true
									@task.completed_points += @campaign.task_custom_4["points"].to_i
									if @task.save
										flash[:notice] = "You have completed the task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						when "5"
							unless @campaign.task_custom_5["points"].nil?
								unless @task.completed_custom[4] == true
									@task.completed_custom[4] = true
									@task.completed_points += @campaign.task_custom_5["points"].to_i
									if @task.save
										flash[:notice] = "You have completed the task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									else
										UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
										flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "You have already completed this task!"
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement case params[:custom_num] went to the else. This is probably because someone changed the param using a webkit browser").deliver
							flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: complete_custom_task | Issue: The statement if !params[:custom_num].nil? && !params[:custom_num].empty? went to the else. Since we hardcoded this param into the url on the campaign index page, odds are someone is using a webkit browser to fuck with the site.").deliver
					flash[:error] = "An error occurred. We have been notified. Please try again later."
					redirect_to "#{root_url}campaign/#{@campaign.link}"
				end
			end
		else
			redirect_to root_url
		end
	end

	def undo_custom_task
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				redirect_to root_url
			else
				if !params[:custom_num].nil? && !params[:custom_num].empty?
					@task = @campaign.tasks.where(user_id: current_user.id).first
					unless @task.nil?
						if Redeem.where(user_id: @task.user_id, campaign_id: @campaign.id).first.nil?
							case params[:custom_num]
							when "1"
								unless @campaign.task_custom_1["points"].nil?
									unless @task.completed_custom[0] == false
										@task.completed_custom[0] = false
										@task.completed_points -= @campaign.task_custom_1["points"].to_i
										if @task.save
											flash[:notice] = "You have undone the task!"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
											flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "You have not yet completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							when "2"
								unless @campaign.task_custom_2["points"].nil?
									unless @task.completed_custom[1] == false
										@task.completed_custom[1] = false
										@task.completed_points -= @campaign.task_custom_2["points"].to_i
										if @task.save
											flash[:notice] = "You have undone the task!"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
											flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "You have not yet completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							when "3"
								unless @campaign.task_custom_3["points"].nil?
									unless @task.completed_custom[2] == false
										@task.completed_custom[2] = false
										@task.completed_points -= @campaign.task_custom_3["points"].to_i
										if @task.save
											flash[:notice] = "You have undone the task!"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
											flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "You have not yet completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							when "4"
								unless @campaign.task_custom_4["points"].nil?
									unless @task.completed_custom[3] == false
										@task.completed_custom[3] = false
										@task.completed_points -= @campaign.task_custom_4["points"].to_i
										if @task.save
											flash[:notice] = "You have undone the task!"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
											flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "You have not yet completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							when "5"
								unless @campaign.task_custom_5["points"].nil?
									unless @task.completed_custom[4] == false
										@task.completed_custom[4] = false
										@task.completed_points -= @campaign.task_custom_5["points"].to_i
										if @task.save
											flash[:notice] = "You have undone the task!"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement: if @task.save, did not save and instead went to the else portion below.").deliver
											flash[:error] = "An error occurred while trying to save. We have been notified. Please try again later."
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "You have not yet completed this task!"
										redirect_to "#{root_url}campaign/#{@campaign.link}"
									end
								else
									flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
									redirect_to "#{root_url}campaign/#{@campaign.link}"
								end
							else
								UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement case params[:custom_num] went to the else. This is probably because someone changed the param using a webkit browser").deliver
								flash[:error] = "An error occurred while trying to look up the campaign. We have been notified. Please try again later."
								redirect_to "#{root_url}campaign/#{@campaign.link}"
							end
						else
							flash[:error] = "Your have already completed this campaign and earned it's gift. Once a campaign is completed, you can no longer undo tasks."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement unless @task.nil? went to the else. At this point, the user should already have had a task created, but for some reason, they do not yet have a task for the campaign.").deliver
						flash[:error] = "An error occurred while trying to find your information. We have been notified. Please try again later."
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: undo_custom_task | Issue: The statement if !params[:custom_num].nil? && !params[:custom_num].empty? went to the else. Since we hardcoded this param into the url on the campaign index page, odds are someone is using a webkit browser to fuck with the site.").deliver
					flash[:error] = "An error occurred. We have been notified. Please try again later."
					redirect_to "#{root_url}campaign/#{@campaign.link}"
				end
			end
		else
			redirect_to root_url
		end
	end

	def track_pinterest_click
		if request.xhr?
			if current_user
				params_campaign = params[:campaign].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					render :text => "ERROR"
				else
					unless params[:addClick].nil? || params[:campaignLink].nil? || params[:addClick]!="true" || params[:campaignLink].downcase!=params_campaign
						@campaign.pinterest_clicks += 1
						if @campaign.save(validate: false)
							render :text => "SUCCESS"
						else
							render :text => "ERROR"
						end
					else
						render :text => "ERROR"
					end
				end
			else
				render :text => "ERROR"
			end
		else
			redirect_to root_url
		end
	end

	def track_twitter_click
		if request.xhr?
			if current_user
				params_campaign = params[:campaign].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					render :text => "ERROR"
				else
					unless params[:addClick].nil? || params[:addClick]!="true"
						@campaign.twitter_clicks += 1
						if @campaign.save(validate: false)
							render :text => "SUCCESS"
						else
							render :text => "ERROR"
						end
					else
						render :text => "ERROR"
					end
				end
			else
				render :text => "ERROR"
			end
		else
			redirect_to root_url
		end
	end

	def track_linkedin_click
		if request.xhr?
			if current_user
				params_campaign = params[:campaign].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					render :text => "ERROR"
				else
					unless params[:addClick].nil? || params[:campaignLink].nil? || params[:addClick]!="true" || params[:campaignLink].downcase!=params_campaign
						@campaign.linkedin_clicks += 1
						if @campaign.save(validate: false)
							render :text => "SUCCESS"
						else
							render :text => "ERROR"
						end
					else
						render :text => "ERROR"
					end
				end
			else
				render :text => "ERROR"
			end
		else
			redirect_to root_url
		end
	end

	def track_google_plus_click
		if request.xhr?
			if current_user
				params_campaign = params[:campaign].downcase
				campaign = Campaign.where(:link => params_campaign).first
				if campaign.present?
					@campaign = campaign
				end
				if campaign.nil?
					render :text => "ERROR"
				else
					unless params[:addClick].nil? || params[:campaignLink].nil? || params[:addClick]!="true" || params[:campaignLink].downcase!=params_campaign
						@campaign.google_plus_clicks += 1
						if @campaign.save(validate: false)
							render :text => "SUCCESS"
						else
							render :text => "ERROR"
						end
					else
						render :text => "ERROR"
					end
				end
			else
				render :text => "ERROR"
			end
		else
			redirect_to root_url
		end
	end

	def tumblr_auth
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				flash[:error] = "The campaign you want to post to Tumblr could not be found. Please try again."
				redirect_to root_url
			else
				if current_user.tumblr_token.nil? || current_user.tumblr_secret.nil? || current_user.tumblr_token.blank? || current_user.tumblr_secret.blank?
					session[:tumblr_campaign] = @campaign.link
					redirect_to '/auth/tumblr'
				else
					Tumblr.configure do |config|
						if Rails.env.production?
							config.consumer_key = "n0UjPDfQllFWOqYvxudHIez5nc4cMTmLeoFabJXn0VvBIYqM8E"
							config.consumer_secret = "xbjErcTpXvfnrHpuUM1rHNY7VcqBMAdv5GIXcRHNYYh5wDhnZU"
						else
							config.consumer_key = "FdB7CU7UBPtvVULdOzWjcz0oGThl10jPQdQb2j89GbBgRBjFZY"
							config.consumer_secret = "j2R5FJnIoDjtjQXFZULSdb6hYkH4Ur5b84IQZrLAxsoFdOvdND"
						end
						config.oauth_token = current_user.tumblr_token
						config.oauth_token_secret = current_user.tumblr_secret
					end
					client = Tumblr::Client.new
					if client.info["status"] == 401 && client.info["msg"]=="Not Authorized" # CHANGE THIS
						session[:tumblr_campaign] = @campaign.link
						redirect_to '/auth/tumblr'
					else
						unless client.info["user"]["blogs"].nil?
							redirect_to "/campaign/#{@campaign.link}/tumblr_blogs"
						else
							flash[:error] = "An error occured while trying to retrieve your Tumblr account information. We have been notified. Please try again later."
							unless current_user.email.nil? || current_user.email.blank?
								theemail = current_user.email
							else
								theemail = "No Email Available"
							end
							UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: tumblr_auth | Issue: The statement: unless client.info[\"user\"][\"blogs\"].nil? went to the else. This means there was an error authenticating, but it wasn't the usual 'Not Authorized' error. | Here is the client status: #{client.info["status"]} | Here is the message: #{client.info["msg"]} | Here is the user's email: #{theemail}").deliver
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					end
				end
			end
		else
			redirect_to "#{root_url}campaign/#{@campaign.link}"
		end
	end

	def tumblr_blogs
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				flash[:error] = "The campaign you want to post to Tumblr could not be found. Please try again."
				redirect_to root_url
			else
				Tumblr.configure do |config|
					if Rails.env.production?
						config.consumer_key = "n0UjPDfQllFWOqYvxudHIez5nc4cMTmLeoFabJXn0VvBIYqM8E"
						config.consumer_secret = "xbjErcTpXvfnrHpuUM1rHNY7VcqBMAdv5GIXcRHNYYh5wDhnZU"
					else
						config.consumer_key = "FdB7CU7UBPtvVULdOzWjcz0oGThl10jPQdQb2j89GbBgRBjFZY"
						config.consumer_secret = "j2R5FJnIoDjtjQXFZULSdb6hYkH4Ur5b84IQZrLAxsoFdOvdND"
					end
					config.oauth_token = current_user.tumblr_token
					config.oauth_token_secret = current_user.tumblr_secret
				end
				@client = Tumblr::Client.new
			end
		else
			redirect_to "#{root_url}campaign/#{@campaign.link}"
		end
	end

	def tumblr_content
		if current_user
			params_campaign = params[:campaign].downcase
			campaign = Campaign.where(:link => params_campaign).first
			if campaign.present?
				@campaign = campaign
			end
			if campaign.nil?
				flash[:error] = "The campaign you want to post to Tumblr could not be found. Please try again."
				redirect_to root_url
			else
				@share = @campaign.shares.where(user_id: current_user.id).first
				unless @share.nil?
					@link = params[:link]
				else
					flash[:error] = "The share you are trying to post to Tumblr could not be found. Please try again."
					redirect_to "#{root_url}campaign/#{@campaign.link}"
				end
			end
		else
			redirect_to "#{root_url}campaign/#{@campaign.link}"
		end
	end

	def tumblr_post
		params_campaign = params[:campaign].downcase
		campaign = Campaign.where(:link => params_campaign).first
		if campaign.present?
			@campaign = campaign
		end
		if campaign.nil?
			flash[:error] = "The campaign you want to post to Tumblr could not be found. Please try again."
			redirect_to root_url
		else
			unless params[:link].nil? || params[:link].empty?
				unless params[:content].nil? || params[:title].nil? || params[:content].empty? || params[:title].empty?
					if current_user
						share = @campaign.shares.where(user_id: current_user.id).first
						unless share.nil?
							unless params[:content].match(share.link)
								flash[:error] = "Uh Oh! It doesn't look like you added the link to your Share Page to the content. Please try again."
								redirect_to "#{root_url}campaign/#{@campaign.link}/tumblr_content?#{{link: params[:link]}.to_query}&#{{title_text: params[:title]}.to_query}&#{{content_text: params[:content]}.to_query}"
							else
								unless params[:content].match(@campaign.campaign_image_url(:standard).to_s)
									flash[:error] = 'Uh Oh! You forgot to add the Campaign Image! Click the "Copy Image Link to Clipboard" button, then click the "Insert Image" button (in the text editor on the far right), and paste in the link!'
									redirect_to "#{root_url}campaign/#{@campaign.link}/tumblr_content?#{{link: params[:link]}.to_query}&#{{title_text: params[:title]}.to_query}&#{{content_text: params[:content]}.to_query}"
								else
									if URI.unescape(params[:content]).length >= 200
										Tumblr.configure do |config|
											if Rails.env.production?
												config.consumer_key = "n0UjPDfQllFWOqYvxudHIez5nc4cMTmLeoFabJXn0VvBIYqM8E"
												config.consumer_secret = "xbjErcTpXvfnrHpuUM1rHNY7VcqBMAdv5GIXcRHNYYh5wDhnZU"
											else
												config.consumer_key = "FdB7CU7UBPtvVULdOzWjcz0oGThl10jPQdQb2j89GbBgRBjFZY"
												config.consumer_secret = "j2R5FJnIoDjtjQXFZULSdb6hYkH4Ur5b84IQZrLAxsoFdOvdND"
											end
											config.oauth_token = current_user.tumblr_token
											config.oauth_token_secret = current_user.tumblr_secret
										end
										client = Tumblr::Client.new
										post_result = client.text(params[:link], {:title => params[:title], :body => params[:content]})
										unless post_result["id"].nil?
											@campaign.tumblr_clicks += 1
											@campaign.save(validate: false)
											flash[:notice] = "You have successfully posted to Tumblr! Here is the link to your blog post: <a href='http://#{params[:link]}/post/#{post_result["id"]}' target='_blank'>http://#{params[:link]}/post/#{post_result["id"]}</a>"
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										else
											flash[:error] = "An error occured while trying to post to Tumblr. We have been notified. Please try again later"
											unless current_user.email.nil? || current_user.email.blank?
												theemail = current_user.email
											else
												theemail = "No Email Available"
											end
											UserMailer.email_brice_error("Controller: campaign_controller.rb | Action: tumblr_post | Issue: The statement: unless post_result[\"id\"].nil? went to the else. | Here is the post_result status: #{post_result["status"]} | Here is the message: #{post_result["msg"]} | Here is the user's email: #{theemail}").deliver
											redirect_to "#{root_url}campaign/#{@campaign.link}"
										end
									else
										flash[:error] = "Uh Oh! Your blog content is not at least 200 characters! It's only #{URI.unescape(params[:content]).length}. Please make it longer, then try again!"
										redirect_to "#{root_url}campaign/#{@campaign.link}/tumblr_content?#{{link: params[:link]}.to_query}&#{{title_text: params[:title]}.to_query}&#{{content_text: params[:content]}.to_query}"
									end
								end
							end
						else
							flash[:error] = "The share you are trying to post to Tumblr could not be found. Please try again."
							redirect_to "#{root_url}campaign/#{@campaign.link}"
						end
					else
						redirect_to "#{root_url}campaign/#{@campaign.link}"
					end
				else
					flash[:error] = "You must fill out all fields in the Tumblr Post form. Please try again."
					redirect_to "#{root_url}campaign/#{@campaign.link}/tumblr_content?#{{link: params[:link]}.to_query}&#{{title_text: params[:title]}.to_query}&#{{content_text: params[:content]}.to_query}"
				end
			else
				redirect_to "#{root_url}campaign/#{@campaign.link}"
			end
		end
	end

end
