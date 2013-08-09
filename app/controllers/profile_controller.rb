class ProfileController < ApplicationController

	def index
		params_profile = params[:profile].downcase
		user = User.where(:nickname => params_profile).first
		if user.present?
		  @profile = user
		  @campaign =  user.campaigns.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 12
		  # @gallery = user.images.order_by([:date, :desc])
		  # @images = Image.all.order_by([:date, :desc])
		end
		if user.nil?
		  redirect_to root_url
		end
	end

	def profile_settings
		if current_user
			@user = User.find(current_user.id)
		else
			flash[:error] = "You must be logged in as a buddee to perform that action."
			redirect_to root_url
		end
	end

	def account_settings
		if current_user
			@user = User.find(current_user.id)
		else
			flash[:error] = "You must be logged in as a buddee to perform that action."
			redirect_to root_url
		end
	end

	def update_location
		@user = User.find(current_user.id)
		unless params[:user][:location].blank?
			@location = Location.find(params[:user][:location])
			@user.location_id = @location.id
		end

		if @user.update_attributes(params[:user])
	      flash[:notice] = "Location updated."
	      redirect_to root_url
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to root_url
	    end
	end

	def password_settings
		if current_user
			if current_user.provider.nil?
				@user = User.find(current_user.id)
			else
				redirect_to root_url
			end
		end
	end

	def follow
		if current_user
			@user = User.where(:nickname => params[:profile]).first
			@follow = User.add_following(Time.now, @user._id, current_user._id, root_url)
			
			if @follow
				@return = 'true'
				respond_to do |format|
					format.html
					format.js
				end
			else
				respond_to do |format|
					format.html
					format.js
				end
			end
		else
			#redirect_to '/signup'
		end
	end

	def unfollow
		if current_user
			@user = User.where(:nickname => params[:profile]).first
			@unfollow = User.remove_follower(@user._id, current_user._id)
			
			if @unfollow
				#flash[:notice] = "Unfollow"
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			else
				#flash[:notice] = "Oops"
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			end
		else
			#redirect_to '/signup'
		end
	end

	def list_follow
		if current_user
			@user = User.where(:nickname => params[:profile]).first
			@follow = User.add_following(Time.now, @user._id, current_user._id, root_url)
			
			if @follow
				#flash[:notice] = "Following"
				@div = @user.nickname.to_s + '_follow'
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			else
				flash[:notice] = "Oops"
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			end

		else
			#redirect_to '/signup'
			respond_to do |format|
				format.html
				format.js
			end
		end

	end

	def list_unfollow
		if current_user
			@user = User.where(:nickname => params[:profile]).first
			@unfollow = User.remove_follower(@user._id, current_user._id)
			
			if @unfollow
				@div = @user.nickname.to_s + '_follow'
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			else
				flash[:notice] = "Oops"
				#redirect_to(:action => 'index')
				respond_to do |format|
					format.html
					format.js
				end
			end
		else
			#redirect_to '/signup'
			respond_to do |format|
				format.html
				format.js
			end
		end
	end

	def profile_settings_update
		@user = User.find(current_user.id)
	    if @user.update_attributes(params[:user])
	      flash[:notice] = "Successfully updated."
	      redirect_to(:controller => 'profile', :action => 'profile_settings')
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to(:controller => 'profile', :action => 'profile_settings')
	    end
	end

	def account_settings_update
		@user = User.find(current_user.id)
	    if @user.update_attributes(params[:user])
	      flash[:notice] = "Successfully updated."
	      redirect_to(:controller => 'profile', :action => 'account_settings')
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to(:controller => 'profile', :action => 'account_settings')
	    end
	end

	def password_settings_update
		@user = User.find(current_user.id)
		user = User.authenticate(current_user.email, params[:current_password])
		if user
			if params[:user][:password] == params[:user][:password_confirmation]
			    if @user.update_attributes(params[:user])
			      flash[:notice] = "Successfully updated."
			      redirect_to(:controller => 'profile', :action => 'password_settings')
			    else
			      flash[:notice] = "Uh oh... something went wrong. Please try again."
			      redirect_to(:controller => 'profile', :action => 'password_settings')
			    end
			elsif params[:user][:password] != params[:user][:password_confirmation]
				flash[:notice] = "Correctly confirm your new password"
			    redirect_to(:controller => 'profile', :action => 'password_settings')
			end
		else
			flash[:notice] = "Current password is incorrect"
		    redirect_to(:controller => 'profile', :action => 'password_settings')
		end
	end

	def update_profile_image
	    @profile_image = User.find(current_user.id)
	    @profile_image.profile_image.remove!
	    if @profile_image.update_attributes(params[:user])
	      flash[:notice] = "Successfully uploaded image."
	      redirect_to :action => 'profile_settings'
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      render :action => 'profile_settings'
	    end
	end

	def profile_nickname_settings
		@user = User.find(current_user.id)
	end

	def profile_nickname_update
		@user = User.find(current_user.id)
		user_nickname_before = params[:user][:nickname]

	    nickname_regex = /^[a-zA-Z0-9_\s]*$/i
	    if user_nickname_before.match(/^[a-zA-Z0-9_\s]*$/i).nil?
	    	flash[:notice] = "Invalid username! Alphanumerics only."
	    	redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
	    else
		    if user_nickname_before.blank?
		    	flash[:notice] = "Username can't be blank"
			    redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
			else
			    if user_nickname_before.nil? || user_nickname_before == ""
			      user_nickname_after = nil
			    elsif user_nickname_before != nil
			      user_nickname_after = user_nickname_before.downcase
			    end

			    check_exist = User.first(conditions: { nickname: user_nickname_after})
			    if check_exist != nil
			      if @user.nickname == user_nickname_after
			        flash[:notice] = "This is your current username"
			        redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
			      elsif check_exist.nickname != nil
			        flash[:notice] = "Username already exists. Please try another."
			        redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
			      elsif check_exist.nickname == nil
			        flash[:notice] = "Please choose a username."
			        redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
			      end
			    elsif check_exist == nil
			      @user.nickname = user_nickname_after
			      if @user.save
				      flash[:notice] = "Username successfully updated."
				      redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
				  else
				      flash[:notice] = "Uh oh... something went wrong. Please try again."
				      redirect_to(:controller => 'profile', :action => 'profile_nickname_settings')
				  end
			      #flash[:notice] = "Nickname is now yours!"
			    end
			end
		end
	end

end
