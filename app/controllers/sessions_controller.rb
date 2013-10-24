class SessionsController < ApplicationController
  
  def new
    if current_user
      flash[:notice] = "You are already signed in!"
      redirect_to '/home'
    end
  end

  def create
    auth = request.env["omniauth.auth"]
    # check_user = User.exists?(provider: auth["provider"], uid: auth["uid"])
    if auth.provider == 'tumblr'
      the_user = current_user
      unless current_user.nil?
        the_user.tumblr_token = auth.credentials.token
        the_user.tumblr_secret = auth.credentials.secret
        if the_user.save
          flash[:notice] = "You have just connected your brandbuddee and Tumblr accounts. You may post to Tumblr whenever you like!"
          redirect_to "#{root_url}campaign/#{session[:tumblr_campaign]}/tumblr_blogs"
          session[:tumblr_campaign] = nil
        else
          flash[:error] = "An error occurred while trying to update your Tumblr information. We have been notified. Please try again later."
          unless current_user.email.nil? || current_user.email.blank?
            theemail = current_user.email
          else
            theemail = "No Email Available"
          end
          UserMailer.email_brice_error("Controller: sessions_controller.rb | Action: create | Issue: The statement: if the_user.save went to the else. | Here is the user's email: #{theemail}").deliver
          redirect_to root_url
        end
      else
        flash[:error] = "Please log in before attempting to post to Tumblr"
        redirect_to root_url
      end
    else
      if !session[:account_type].nil? && session[:account_type] == "brand" # Brand Auth
        session[:account_type] = nil
        if current_user
          flash[:error] = "You can't be logged in as a buddee to log in or sign up as a brand"
          redirect_to "/home"
        elsif current_brand
          flash[:error] = "You are already logged in as a brand!"
          redirect_to "/brands/dashboard"
        else
          if auth.provider == "facebook"
            brand = Brand.from_omniauth_facebook(auth)
            if brand.date > DateTime.now - 1.minute # If Brand created in the last minute
              session[:brand_profile_unfinished] = true
              cookies[:brand_tour] = {:value => true, :expires => Time.now + 1.month}
            end
            brand.last_login = DateTime.now
            brand.save(validate: false)
            session[:brand_id] = brand.id
            if brand.email.nil? || brand.email.blank?
              redirect_to "/brands/enter-email"
            elsif brand.nickname.nil? || brand.nickname.blank?
              redirect_to "/brands/enter-nickname"
            else
              flash[:info] = "You are now signed in with Facebook."
              redirect_to "/brands/dashboard"
            end
          elsif auth.provider == "twitter"
            brand = Brand.from_omniauth_twitter(auth)
            if brand.date > DateTime.now - 1.minute # If Brand created in the last minute
              session[:brand_profile_unfinished] = true
              cookies[:brand_tour] = {:value => true, :expires => Time.now + 1.month}
            end
            brand.last_login = DateTime.now
            brand.save(validate: false)
            session[:brand_id] = brand.id
            if brand.email.nil? || brand.email.blank?
              redirect_to "/brands/enter-email"
            elsif brand.nickname.nil? || brand.nickname.blank?
              redirect_to "/brands/enter-nickname"
            else
              flash[:info] = "You are now signed in with Twitter."
              redirect_to "/brands/dashboard"
            end
          end
        end
      else # User Auth (Both Regular and FB Embed Widget)
 ######################################################
 #          BEGIN FACEBOOK STATE PARAM                #
 ######################################################
      	unless params[:state].nil? # Brand Auth / FB & Website Embed Auth
      		if params[:state].start_with?("website_embed_user_auth_") # Website Embed Auth/Reauth
      			camp_id = params[:state][24..-1]
      			@campaign = Campaign.where(_id: camp_id).first
      			unless @campaign.nil?
      				if current_user # User FB reauth
      					already_joined = false
      					current_user.campaigns.each do |c|
      						if c.id == @campaign.id
      							already_joined = true
      						end
      					end
      					if User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
      						if current_user.email == User.where(provider: auth["provider"], uid: auth["uid"]).first.email
      							current_user.oauth_token = auth["credentials"]["token"]
      							unless auth["credentials"]["expires_at"].nil?
      								current_user.oauth_expires_at = auth["credentials"]["expires_at"]
      							else
      								current_user.oauth_expires_at = (DateTime.now + 60.days).to_i.to_s
      							end
      							if current_user.save
      								if current_user.nickname.blank?
      									flash[:success] = "Your account has been connected with Facebook! Please pick a nickname to continue."
      									redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
      								else
      									flash[:success] = "Your account has been connected with Facebook!"
      									if already_joined==true
      										redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
      									else
      										redirect_to "/campaign/#{@campaign.link}/go_viral"
      									end
      								end
      							else
      								if current_user.nickname.blank?
      									flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again after choosing a nickname."
      									redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
      								else
      									flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again."
      									if already_joined==true
      										redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
      									else
      										redirect_to "/campaign/#{@campaign.link}/go_viral"
      									end
      								end
      							end
      						else
      							flash[:error] = "The Facebook Account you are trying to connect with already belongs to another buddee account. Please log in with a different Facebook Account and try again."
      							if already_joined==true
  										redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
  									else
      								redirect_to "/campaign/#{@campaign.link}/go_viral"
      							end
      						end
      					else
      						current_user.oauth_token = auth["credentials"]["token"]
    							unless auth["credentials"]["expires_at"].nil?
    								current_user.oauth_expires_at = auth["credentials"]["expires_at"]
    							else
    								current_user.oauth_expires_at = (DateTime.now + 60.days).to_i.to_s
    							end
    							if current_user.save
    								flash[:success] = "Your account has been connected with Facebook!"
    								if already_joined==true
  										redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
  									else
    									redirect_to "/campaign/#{@campaign.link}/go_viral"
    								end
    							else
    								flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again."
    								if already_joined==true
  										redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
  									else
    									redirect_to "/campaign/#{@campaign.link}/go_viral"
    								end
    							end
      					end
      				else # User signin/signup
        				if User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
		              user = User.where(uid: auth["uid"], provider: auth["provider"]).first
		              User.update_with_omniauth(auth, user)
		              user.last_login = Time.now
		              user.save
		              session[:user_id] = user.id
	                unless @campaign.already_has_user_share?(user)
	                  @left = @campaign.limit - @campaign.redeems.size
	                  unless @left < 1 || @campaign.end_date < Time.now
	                    @campaign.user_ids << user.id
	                    share_link = Share.assign_link
	                    the_share = @campaign.shares.create!(date: Time.now, link: share_link, user_id: user.id, campaign_id: @campaign.id, url: @campaign.share_link)
	                    @bitly_link = the_share.bitly_share_link
	                    unless @campaign.already_has_user_task?(user)
	                      @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: user.id, campaign_id: @campaign.id)
	                      if @campaign.save(validate: false)
	                        if user.nickname.nil? || user.nickname.blank?
	                          redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
	                        else
	                          redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
	                        end
	                      else
	                        redirect_to "/campaign/#{@campaign.link}/go_viral"
	                      end
	                    else
	                      if user.nickname.nil? || user.nickname.blank?
	                        redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
	                      else
	                        redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
	                      end
	                    end
	                  else
	                    if user.nickname.nil? || user.nickname.blank?
	                      redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
	                    else
	                      flash[:info] = "You are now logged in! Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
	                      redirect_to "/campaign/#{@campaign.link}/go_viral"
	                    end
	                  end
	                else
	                  if user.nickname.nil? || user.nickname.blank?
	                    redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
	                  else
	                    redirect_to "/campaign/#{@campaign.link}/go_viral_joined"
	                  end
	                end
		            else # User Signup
		              taken = User.first(conditions: {email: /^#{auth["info"]["email"]}$/i}) # Case Insensitive
		              if taken.nil? # No user with that email
		                user = User.create_with_omniauth(auth, Time.now)
		                session[:user_id] = user.id
		                @left = @campaign.limit - @campaign.redeems.size
		                unless @left < 1 || @campaign.end_date < Time.now
		                  @campaign.user_ids << user.id
		                  share_link = Share.assign_link
		                  the_share = @campaign.shares.create!(date: Time.now, link: share_link, user_id: user.id, campaign_id: @campaign.id, url: @campaign.share_link)
		                  @bitly_link = the_share.bitly_share_link
		                  @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: user.id, campaign_id: @campaign.id)
		                  if @campaign.save(validate: false)
		                    redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
		                  else
		                    redirect_to "/campaign/#{@campaign.link}/go_viral"
		                  end
		                else
		                  redirect_to "/campaign/#{@campaign.link}/go_viral_create_username"
		                end
		              else # Already a user with that email
		                flash[:error] = "The Email Address associated with your Facebook Account has already been used signup for brandbuddee. Please use a Facebook Account with a different Email Address."
		                redirect_to "/campaign/#{@campaign.link}/go_viral"
		              end
		            end
		          end
      			else
      				render text: "An error occurred while trying to find the campaign you are looking for. Please try again later..."
      			end
      		elsif params[:state].start_with?("brand_connect_with_fb_") # Brand FB Reconnect
      			camp_id = params[:state][22..-1]
      			@campaign = Campaign.where(_id: camp_id).first
      			unless @campaign.nil?
			        if current_brand
			          @brand = Brand.find(current_brand.id)
		            if @brand.provider == "facebook"
		              if @brand.uid == auth["uid"]
		                @brand.facebook_token = auth["credentials"]["token"]
		                unless auth["credentials"]["expires_at"].nil?
		            			@brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
		            		else
		            			@brand.facebook_expires = DateTime.now + 60.days
		            		end
		                if @brand.save(validate: false)
		                  redirect_to "/brands/campaigns/viral-install-fb?_id=#{@campaign.id}"
		                else
		                  flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
		                  redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		                end
		              else
		                flash[:error] = "The Facebook Account you are trying to update with does not belong to this Brand Account. Please login with a different Facebook Account and try again."
		                redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		              end
		            elsif @brand.provider == "email"
		              unless Brand.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
		                @brand.facebook_token = auth["credentials"]["token"]
		                unless auth["credentials"]["expires_at"].nil?
		                  @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
		                else
		                  @brand.facebook_expires = DateTime.now + 60.days
		                end
		                if @brand.save(validate: false)
		                  redirect_to "/brands/campaigns/viral-install-fb?_id=#{@campaign.id}"
		                else
		                  flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
		                  redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		                end
		              else
		                flash[:error] = "The Facebook Account you are trying to connect with belongs to an existing Brand Account. Please login with a different Facebook Account and try again."
		                redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		              end
		            elsif @brand.provider == "twitter"
		            	unless Brand.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
		                @brand.facebook_token = auth["credentials"]["token"]
		                unless auth["credentials"]["expires_at"].nil?
		                  @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
		                else
		                  @brand.facebook_expires = DateTime.now + 60.days
		                end
		                if @brand.save(validate: false)
		                  redirect_to "/brands/campaigns/viral-install-fb?_id=#{@campaign.id}"
		                else
		                  flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
		                  redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		                end
		              else
		                flash[:error] = "The Facebook Account you are trying to connect with belongs to an existing Brand Account. Please login with a different Facebook Account and try again."
		                redirect_to "/brands/campaigns/viral?_id=#{@campaign.id}"
		              end
		            else
		              redirect_to root_url
		            end
			        else
			          redirect_to root_url
			        end
			      else
			      	flash[:error] = "The campaign you are trying to install to your Facebook Page could not be found. Please try again."
	            redirect_to "/brands/dashboard"
			      end
          elsif params[:state].start_with?("brand_fb_story_connect") # Brand FB story connect
            if current_brand
              @brand = Brand.find(current_brand.id)
              if @brand.provider == "facebook"
                if @brand.uid == auth["uid"]
                  @brand.facebook_token = auth["credentials"]["token"]
                  unless auth["credentials"]["expires_at"].nil?
                    @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
                  else
                    @brand.facebook_expires = DateTime.now + 60.days
                  end
                  if @brand.save(validate: false)
                    redirect_to "/brands/campaigns/create"
                  else
                    flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
                    redirect_to "/brands/campaigns/create"
                  end
                else
                  flash[:error] = "The Facebook Account you are trying to update with does not belong to this Brand Account. Please login with a different Facebook Account and try again."
                  redirect_to "/brands/dashboard"
                end
              elsif @brand.provider == "email"
                # unless Brand.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
                  @brand.facebook_token = auth["credentials"]["token"]
                  unless auth["credentials"]["expires_at"].nil?
                    @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
                  else
                    @brand.facebook_expires = DateTime.now + 60.days
                  end
                  if @brand.save(validate: false)
                    redirect_to "/brands/campaigns/create"
                  else
                    flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
                    redirect_to "/brands/campaigns/create"
                  end
                # else
                #   flash[:error] = "The Facebook Account you are trying to connect with belongs to an existing Brand Account. Please login with a different Facebook Account and try again."
                #   redirect_to "/brands/dashboard"
                # end
              elsif @brand.provider == "twitter"
                unless Brand.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
                  @brand.facebook_token = auth["credentials"]["token"]
                  unless auth["credentials"]["expires_at"].nil?
                    @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
                  else
                    @brand.facebook_expires = DateTime.now + 60.days
                  end
                  if @brand.save(validate: false)
                    redirect_to "/brands/campaigns/create"
                  else
                    flash[:error] = "An error occurred while trying to update your Brand Account with Facebook Connection Info. Please try again."
                    redirect_to "/brands/dashboard"
                  end
                else
                  flash[:error] = "The Facebook Account you are trying to connect with belongs to an existing Brand Account. Please login with a different Facebook Account and try again."
                  redirect_to "/brands/dashboard"
                end
              else
                redirect_to root_url
                flash[:error] = "No provider found"
              end
            else
              flash[:error] ="You need to login as a brand"
              redirect_to root_url
            end
			    elsif params[:state].start_with?("fb_embed_user_auth_") # User Auth For FB Embed Widget
			    	str = params[:state][19..-1]
						campaign_id = str[0..(str.index("_")-1)]
						str = str[str.index("_")+1..-1]
						page_id = str[0..str.index("_")-1]
						str = str[str.index("_")+1..-1]
						liked = str[0..str.index("_")-1]
						str = str[str.index("_")+1..-1]
						admin = str
						@campaign = Campaign.find(campaign_id)
						unless @campaign.nil?
						  if User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] }) # User Login
						    user = User.where(uid: auth["uid"], provider: auth["provider"]).first
						    User.update_with_omniauth(auth, user)
						    user.last_login = Time.now
						    user.save
						    session[:user_id] = user.id
						    if admin.to_s == "true" # User IS an admin of the Facebook Page
						      if user.nickname.nil? || user.nickname.blank?
						        redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      else
						        redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      end
						    else # User is NOT an admin of the Facebook Page
						      unless @campaign.already_has_user_share?(user)
						        @left = @campaign.limit - @campaign.redeems.size
						        unless @left < 1 || @campaign.end_date < Time.now
						          @campaign.user_ids << user.id
						          share_link = Share.assign_link
						          the_share = @campaign.shares.create!(date: Time.now, link: share_link, user_id: user.id, campaign_id: @campaign.id, url: @campaign.share_link)
						          @bitly_link = the_share.bitly_share_link
						          unless @campaign.already_has_user_task?(user)
						            @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: user.id, campaign_id: @campaign.id)
						            if @campaign.save(validate: false)
						              if user.nickname.nil? || user.nickname.blank?
						                redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						              else
						                redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						              end
						            else
						              redirect_to "/fb-campaign-embed?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						            end
						          else
						            if user.nickname.nil? || user.nickname.blank?
						              redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						            else
						              redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						            end
						          end
						        else
						          if user.nickname.nil? || user.nickname.blank?
						            redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          else
						            flash[:info] = "You are now logged in! Unfortunately, this campaign has expired. Head over to brandbuddee.com to see a full list of current campaigns!"
						            redirect_to "/fb-error-page?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          end
						        end
						      else
						        if user.nickname.nil? || user.nickname.blank?
						          redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        end
						      end
						    end # End User is not an admin of the Facebook Page
						  else # User Signup
						    taken = User.first(conditions: {email: /^#{auth["info"]["email"]}$/i}) # Case Insensitive
						    if taken.nil? # No user with that email
						      user = User.create_with_omniauth(auth, Time.now)
						      session[:user_id] = user.id
						      @left = @campaign.limit - @campaign.redeems.size
						      unless @left < 1 || @campaign.end_date < Time.now
						        @campaign.user_ids << user.id
						        share_link = Share.assign_link
						        the_share = @campaign.shares.create!(date: Time.now, link: share_link, user_id: user.id, campaign_id: @campaign.id, url: @campaign.share_link)
						        @bitly_link = the_share.bitly_share_link
						        @campaign.tasks.create!(task_1_url: @campaign.engagement_task_left_link, task_2_url: @campaign.engagement_task_right_link, user_id: user.id, campaign_id: @campaign.id)
						        if @campaign.save(validate: false)
						          redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          redirect_to "/fb-campaign-embed?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        end
						      else
						        redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      end
						    else # Already a user with that email
						      flash[:error] = "The Email Address associated with your Facebook Account has already been used signup for brandbuddee. Please use a Facebook Account with a different Email Address."
						      redirect_to "/fb-error-page?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						    end
						  end
						else # Campaign not found
						  redirect_to "/fb-campaign-embed?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						end
					elsif params[:state].start_with?("fb_embed_email_connect_") # FB Embed Widget: Connect Email Signup With Facebook
						str = params[:state][23..-1]
						page_id = str[0..str.index("_")-1]
						str = str[str.index("_")+1..-1]
						liked = str[0..str.index("_")-1]
						str = str[str.index("_")+1..-1]
						admin = str
						user = current_user
						unless user.nil?
						  if user.provider == "facebook"
						    if user.uid == auth["uid"]
						      user.oauth_token = auth["credentials"]["token"]
						      user.oauth_expires_at = auth["credentials"]["expires_at"]
						      if user.save
						        if user.nickname.nil? || user.nickname.blank?
						          redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          if admin.to_s == "true"
						            flash[:info] = "Your account is now connected with Facebook! You may now Post to your Facebook Wall!"
						            redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          else
						            flash[:info] = "Your account is now connected with Facebook! You may now Post to your Facebook Wall!"
						            redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          end
						        end
						      else
						        flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again."
						        if admin.to_s == "true"
						          redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        end
						      end
						    else
						      flash[:error] = "The Facebook account you are trying to connect with already belongs to a buddee account. Please login with a different Facebook account and then try again."
						      if admin.to_s == "true"
						        redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      else
						        redirect_to  "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      end
						    end
						  elsif user.provider != "facebook" && user.provider != "twitter"
						    unless User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
						      user.oauth_token = auth["credentials"]["token"]
						      user.oauth_expires_at = auth["credentials"]["expires_at"]
						      if user.save
						        if user.nickname.nil? || user.nickname.blank?
						          redirect_to "/fb-create-username?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          if admin.to_s == "true"
						            flash[:info] = "Your account is now connected with Facebook! You may now Post to your Facebook Wall!"
						            redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          else
						            flash[:info] = "Your account is now connected with Facebook! You may now Post to your Facebook Wall!"
						            redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						          end
						        end
						      else
						        flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again."
						        if admin.to_s == "true"
						          redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        else
						          redirect_to "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						        end
						      end
						    else
						      flash[:error] = "The Facebook account you are trying to connect with already belongs to a buddee account. Please login with a different Facebook account and then try again."
						      if admin.to_s == "true"
						        redirect_to "/fb-embed-admin?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      else
						        redirect_to  "/fb-joined-campaign?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						      end
						    end
						  end
						else
						  flash[:error] = "An error occurred while trying to connect your account with Facebook. Please try again."
						  redirect_to "/fb-error-page?page_id=#{page_id}&liked=#{liked}&admin=#{admin}"
						end
      		else
      			redirect_to root_url
      		end
      	else # Regular User Auth
          if current_user
            if User.update_with_omniauth(auth, current_user)
              flash[:notice] = "Successfully connected with #{auth.provider.titleize}"
              redirect_to '/home'
            else
              flash[:error] = "This #{auth.provider.titleize} account is already associated with a brandbuddee account"
              redirect_to '/home'
            end
          elsif current_brand
            flash[:error] = "You must not be logged in as a brand to perform that action."
            redirect_to "/brands/dashboard"
          else

            if User.exists?(conditions: { provider: auth["provider"], uid: auth["uid"] })
              user = User.where(uid: auth["uid"], provider: auth["provider"]).first
              User.update_with_omniauth(auth, user)
              # update facebook token attributes
              # User.update_with_omniauth(auth, user)
              user.last_login = Time.now
              user.save
              session[:user_id] = user.id

              #flash[:notice] = "Signed in!"
              redirect_to '/home', :notice => "Signed in!"
            # elsif User.exists?(conditions: { twitter_handle: auth["user_info"]["nickname"] })
            #  user = User.where(twitter_handle: auth["user_info"]["nickname"]).first
            #  User.update_with_omniauth(auth, user)
            #  session[:user_id] = user.id
            #  redirect_to root_url, :notice => "Signed in!"
            else
              # c = cookies[:invite]

              # @invite = Invitation.where(:invite_code => c).first

              # if @invite.nil?
              #   flash[:notice] = "Due to the unexpected amount of signups we have temporarily closed our beta. Feel free to sign up on the <a href='#{root_url}' style='color:green;'>beta list</a> to get an invite!"
              #   redirect_to "#{root_url}signup"
              # else
              #   unless @invite.status == true
                   email = cookies[:e]
                  if auth["provider"] == "twitter"
                    if email.nil?
                      redirect_to(:controller => 'users', :action => 'complete_email')
                    else
                      user = User.create_with_omniauth_twitter(auth, Time.now, email)

                      # @invite.status = true
                      # @invite.success_date = Time.now
                      # @invite.save
                      session[:user_id] = user.id
                      cookies[:user_tour] = {:value => true, :expires => Time.now + 1.month}
                      #WelcomeMailer.welcome_email(current_user).deliver
                      #redirect_to root_url
                      redirect_to(:controller => 'users', :action => 'new')
                    end
                  else
                    if User.first(conditions: {email: /^#{auth["info"]["email"]}$/i}).nil?
                      user = User.create_with_omniauth(auth, Time.now)
                      session[:user_id] = user.id
                      cookies[:user_tour] = {:value => true, :expires => Time.now + 1.month}
                      #WelcomeMailer.welcome_email(current_user).deliver
                      redirect_to(:controller => 'users', :action => 'new')
                    else
                      flash[:error] = "There is already a buddee account registered with the email address associated with that account."
                      redirect_to root_url
                    end
                  end
              #   else
              #     flash[:notice] = "This invitation is no longer valid."
              #     redirect_to "#{root_url}signup"
              #   end
              # end

            end
          end
        end # Regular User Auth
      end # User Auth (Both Regular and FB Embed Widget)
    end # End Facebook/Twitter Auth
  end

  def email_create
    if current_brand
      flash[:error] = "You are already logged in as a brand. You can't log in as a buddee."
      redirect_to "/brands/dashboard"
    else
      begin
      	params[:email].strip!
        user = User.authenticate(params[:email], params[:password])
        if user
          user.last_login = Time.now
          user.save
          session[:user_id] = user.id
          respond_to do |format|
            format.html {
              flash[:notice] = "Signed in!"
              redirect_to "/home"
            }
            format.js {
              flash[:notice] = "Signed in!"
            }
          end
        else
          respond_to do |format|
            format.html {
              flash[:notice] = "Invalid email or password"
              redirect_to "/login"
            }
            format.js {
              flash[:notice] = "Invalid email or password"
            }
          end
        end
      rescue BCrypt::Errors::InvalidSalt
        respond_to do |format|
          format.html {
            flash[:notice] = "Your password seems to be invalid please reset your password by clicking: Forgot your password?"
            redirect_to "/login"
          }
          format.js {
            flash[:notice] = "Your password seems to be invalid please reset your password by clicking: Forgot your password?"
          }
        end
      end
    end
  end

  def destroy
    session[:user_id] = nil
    # redirect_to root_url, :notice => "Logged out!"
    flash[:notice] = "Logged out!"
    redirect_to root_url
  end

  def brand_login
    if current_user
      flash[:error] = "You can't be logged in as a buddee and log in as a brand."
      redirect_to "/home"
    elsif current_brand
      flash[:error] = "You are already logged in as a brand!"
      redirect_to "/brands/dashboard"
    end      
  end

  def brand_email_login
    if current_user
      flash[:error] = "You can't be logged in as a buddee and log in as a brand."
      redirect_to "/home"
    elsif current_brand
      flash[:error] = "You are already logged in as a brand!"
      redirect_to "/brands/dashboard"
    else
    	params[:email_address].strip!
      brand = Brand.where(email: params[:email_address]).first
      if brand
        if brand.provider=="email"
          if brand.authenticate(params[:password_field])
            brand.last_login = DateTime.now
            brand.save(validate: false)
            session[:brand_id] = brand.id
            respond_to do |format|
              format.html {
                flash[:info] = "You are now logged in!"
                redirect_to '/brands/dashboard'
              }
              format.js {
                flash[:info] = "You are now logged in!"
              }
            end
          else
            respond_to do |format|
              format.html {
                flash.now.alert = "Email or password is invalid"
                render "brand_login"
              }
              format.js {
                flash[:info] = "Email or password is invalid"
              }
            end
          end
        elsif brand.provider=="facebook"
          respond_to do |format|
            format.html {
              flash[:error] = "You signed up using Facebook. Please use Facebook to log in."
              redirect_to "/brands/login"
            }
            format.js {
              flash[:info] = "You signed up using Facebook. Please use Facebook to log in."
            }
          end
        else # twitter
          respond_to do |format|
            format.html {
              flash[:error] = "You signed up using Twitter. Please use Twitter to log in."
              redirect_to "/brands/login"
            }
            format.js {
              flash[:info] = "You signed up using Twitter. Please use Twitter to log in."
            }
          end
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = "Email or password is invalid"
            redirect_to "/brands/login"
          }
          format.js {
            flash[:info] = "Email or password is invalid"
          }
        end
      end
    end
  end

  def brand_destroy
    session[:brand_id] = nil
    flash[:info] = "You are now logged out!"
    redirect_to "/brands/login"
  end
  
  def failure
  	flash[:error] = "To login using this provider, you must allow brandbuddee all the neccessary permissions. Please Try Again."
  	redirect_to root_url
  end
end
