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
      elsif !session[:brand_connect_with_fb].nil? # Brand Reconnect w/ FB
        if current_brand
          @brand = Brand.find(current_brand.id)
          @campaign = @brand.campaigns.where(:_id => session[:brand_connect_with_fb]).first
          session[:brand_connect_with_fb] = nil
          unless @campaign.nil?
            if @brand.provider == "facebook"
              if @brand.uid == auth["uid"]
                @brand.facebook_token = auth["credentials"]["token"]
                @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
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
                @brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
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
            end
          else
            flash[:error] = "The campaign you are trying to install to your Facebook Page could not be found. Please try again."
            redirect_to "/brands/dashboard"
          end
        else
          session[:brand_connect_with_fb] = nil
          redirect_to root_url
        end
      else # User Auth (Both Regular and FB Embed Widget)
        unless session[:fb_embed_widget_signup].nil? # User Auth For FB Embed Widget
          str = session[:fb_embed_widget_signup]
          session[:fb_embed_widget_signup] = nil
          campaign_id = str[0..(str.index("|")-1)]
          str = str[str.index("|")+1..-1]
          page_id = str[0..str.index("|")-1]
          str = str[str.index("|")+1..-1]
          liked = str[0..str.index("|")-1]
          str = str[str.index("|")+1..-1]
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
        else
          unless session[:fb_embed_email_connect].nil? # FB Embed Widget Connect Email Signup With Facebook
            str = session[:fb_embed_email_connect]
            session[:fb_embed_email_connect] = nil
            page_id = str[0..str.index("|")-1]
            str = str[str.index("|")+1..-1]
            liked = str[0..str.index("|")-1]
            str = str[str.index("|")+1..-1]
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
                        #WelcomeMailer.welcome_email(current_user).deliver
                        #redirect_to root_url
                        redirect_to(:controller => 'users', :action => 'new')
                      end
                    else
                      user = User.create_with_omniauth(auth, Time.now)

                      # @invite.status = true
                      # @invite.success_date = Time.now
                      # @invite.save
                      session[:user_id] = user.id
                      #WelcomeMailer.welcome_email(current_user).deliver
                      #redirect_to root_url
                      redirect_to(:controller => 'users', :action => 'new')
                    end
                #   else
                #     flash[:notice] = "This invitation is no longer valid."
                #     redirect_to "#{root_url}signup"
                #   end
                # end

              end
            end
          end # Regular User Auth
        end
      end # User Auth (Both Regular and FB Embed Widget)
    end # End Facebook/Twitter Auth
  end

  def email_create
    if current_brand
      flash[:error] = "You are already logged in as a brand. You can't log in as a buddee."
      redirect_to "/brands/dashboard"
    else
      user = User.authenticate(params[:email], params[:password])
      if user
        user.last_login = Time.now
        user.save
        session[:user_id] = user.id
        flash[:notice] = "Signed in!"
        redirect_to "/home"
      else
        flash[:error] = "Invalid email or password"
        redirect_to "/login"
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
      brand = Brand.where(email: params[:email_address]).first
      if brand
        if brand.provider=="email"
          if brand.authenticate(params[:password_field])
            brand.last_login = DateTime.now
            brand.save(validate: false)
            session[:brand_id] = brand.id      
            flash[:info] = "You are now logged in!"
            redirect_to '/brands/dashboard'
          else
            flash.now.alert = "Email or password is invalid"
            render "brand_login"
          end
        elsif brand.provider=="facebook"
          flash[:error] = "You signed up using Facebook. Please use Facebook to log in."
          redirect_to "/brands/login"
        else # twitter
          flash[:error] = "You signed up using Twitter. Please use Twitter to log in."
          redirect_to "/brands/login"
        end
      else
        flash[:error] = "Email or password is invalid"
        redirect_to "/brands/login"
      end
    end
  end

  def brand_destroy
    session[:brand_id] = nil
    flash[:info] = "You are now logged out!"
    redirect_to "/brands/login"
  end
  
end