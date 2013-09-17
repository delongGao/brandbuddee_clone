class WelcomeController < ApplicationController

	def index
		if current_user
			redirect_to '/home'
		elsif current_brand
			redirect_to '/brands/dashboard'
		end
		@recent_campaigns = Campaign.where(:status => "active").excludes(left: false, is_white_label: true).order_by([:date, :desc]).limit(3)
	end

	def new
		@subscriber = Subscriber.new
	end
  
	def share
		redirect_to root_url

		@link = current_uri = request.env['PATH_INFO']
		@link.slice!("/b/")
	end
  
  	def create
	    @value = Subscriber.assign_share_link(:link)
	    @subscriber = Subscriber.new({:email => params[:email], :date => Time.now, :share_link => @value})
	    @check_email = params[:email]
	    
	    if Subscriber.exists?(conditions: { email: @check_email })
	      flash[:notice] = "You're already signed up!"
	      Subscriber.where(email: params[:email]).each do |s|
	        @share_link = s.share_link
	      end
	      respond_to do |format|
	        format.html
	        format.js
	      end
	    else
	      if @subscriber.save
	        #UserMailer.subscriber_confirmation(@subscriber, root_url).deliver
	        #Subscriber.delay(run_at: 5.minutes.from_now).invite(@subscriber.id, root_url)
	        Subscriber.increase_share(params[:link], params[:email])
	        flash[:notice] = "You're subscribed!"
	        Subscriber.where(email: params[:email]).each do |s|
	          @share_link = s.share_link
	        end
	        respond_to do |format|
	          format.html #{ redirect_to(:action => 'index') }
	          format.js
	        end
	      else
	        flash[:notice] = "email is not valid"
	        respond_to do |format|
	          format.html #{ redirect_to(:action => 'index') }
	          format.js
	        end
	      end
	    end
  	end

  	def consolidate_subscribers
  		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
		  		Subscriber.delay.consolidate()
		  		flash[:notice] = 'Subscribers consolidated.'
		  		redirect_to '/users/show'
		  	else
		  		redirect_to root_url
		  	end
		else
			redirect_to root_url
		end
  	end

  	def invite
  		new_invite_code = Invitation.assign_invite_code()

  		@subscriber = Subscriber.find(params[:_id])
  		@subscriber.invitation = Invitation.new(:date => Time.now, :invite_code => new_invite_code, :email => @subscriber.email)
  		#@invite. = @subscriber.create_invitation(date: Time.now, invite_code: new_invite_code, email: @subscriber.email)

  		if @subscriber.save
  			UserMailer.beta_invite(@subscriber.email, @subscriber.invitation.invite_code, root_url).deliver
  			flash[:notice] = "Invitation sent"
  			redirect_to(:controller=>"welcome", :action => 'list')
  		else
  			flash[:notice] = "Uh oh... something went wrong"
  			redirect_to(:controller=>"welcome", :action => 'list')
  		end
  	end

  	def list
  		if current_user
	  		if current_user.account_type == "super admin" || Rails.env.development?
	  			@subscriber = Subscriber.all.order_by([:date, :desc])
	  			@invitation = Invitation.all.order_by([:date, :desc])
	  		else
	  			redirect_to root_url
	  		end
	  	else
	  		redirect_to root_url
	  	end
	end

	def unsubscribe
		@subscriber = Subscriber.where(email: params[:u]).first
		unless @subscriber
			redirect_to root_url
		end
	end

	def unsubscribe_confirm
		unless params[:email_address].nil?
			unless params[:unsubscribe_email] != "yes"
				@subscriber = Subscriber.where(email: params[:email_address]).first
				if @subscriber
					@subscriber.status = false
					unless @subscriber.save
						redirect_to root_url
					end
				else
					redirect_to root_url
				end
			else
				flash[:error] = "To unsubscribe from campaign newsletters, you must check the yes box."
				redirect_to "/email/unsubscribe?u=#{params[:email_address]}"
			end
		else
			redirect_to root_url
		end
	end

	def invite_destroy
		@invite = Invitation.find(params[:_id])
		@invite.destroy
		flash[:notice] = "Invite Destroyed"
		redirect_to(:controller=>"welcome", :action => 'list')
	end

	def destroy
		@subscriber = Subscriber.find(params[:_id])
		@subscriber.destroy
		flash[:notice] = "Subscriber Destroyed"
		redirect_to(:controller=>"welcome", :action => 'list')
	end

	def new_brand
		if current_user
	      	flash[:error] = "You can't be logged in as a buddee and sign up as a brand."
	      	redirect_to "/home"
	    elsif current_brand
	      	flash[:error] = "You are already logged in as a brand!"
	      	redirect_to "/brands/dashboard"
	    else
	    	@brand = Brand.new
	    end
	end

	def create_brand
		if current_user
    	flash[:error] = "You can't be logged in as a buddee and sign up as a brand."
    	redirect_to "/home"
    elsif current_brand
    	flash[:error] = "You are already logged in as a brand!"
    	redirect_to "/brands/dashboard"
    elsif params[:brand].nil?
    	redirect_to "/brands/signup"
    else
			@brand = Brand.new(params[:brand])
			@brand.email = @brand.email.downcase
			@brand.provider = "email"
			@brand.last_login = DateTime.now
			@brand.date = DateTime.now
			if @brand.save
				session[:brand_profile_unfinished] = true
				session[:brand_id] = @brand.id
				cookies[:brand_tour] = {:value => true, :expires => Time.now + 1.month}
				BrandMailer.post_signup(@brand.email, root_url).deliver
				flash[:info] = "You are now signed up! Please choose a nickname to complete the process."
				redirect_to '/brands/enter-nickname'
			else
				render "new_brand"
			end
		end
	end

	def brands_get_email
		if current_brand.nil?
			flash[:notice] = "You must be logged in as a brand to perform that action."
			redirect_to "/brands/login"
		else
			@current_brand = current_brand
		end
	end

	def brands_update_email
		if current_brand.nil?
			flash[:notice] = "You must be logged in as a brand to perform that action."
			redirect_to "/brands/login"
		else
			@current_brand = current_brand
			unless params[:email_address].nil? || params[:email_address].blank? || !params[:email_address].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i) || params[:email_address].length < 6 || params[:email_address].length > 100
				if Brand.is_unique_email(params[:email_address])
					@current_brand.email = params[:email_address].downcase
					@current_brand.last_updated = DateTime.now
					@current_brand.save!(validate: false)
					BrandMailer.post_signup(@current_brand.email, root_url).deliver
					if @current_brand.nickname.nil? || @current_brand.nickname.blank?
						redirect_to "/brands/enter-nickname"
					else
						flash[:info] = "You are now logged in!"
						redirect_to "/brands/dashboard"
					end
				else
					flash[:error] = "That email address has already been taken. Please choose another."
					redirect_to "/brands/enter-email"
				end
			else
				flash[:error] = "You must enter a valid email address between 6-100 characters."
				redirect_to "/brands/enter-email"
			end			
		end			
	end

	def brands_get_nickname
		if current_brand.nil?
			flash[:notice] = "You must be logged in as a brand to perform that action."
			redirect_to "/brands/login"
		else
			@current_brand = current_brand
		end
	end

	def brands_update_nickname
		unless current_brand.nil?
			@current_brand = current_brand
			unless params[:nickname].nil? || params[:nickname].blank? || !params[:nickname].match(/\A[-\w]*\z/) || params[:nickname].length > 45
				if Brand.is_unique_nickname(params[:nickname])
					@current_brand.nickname = params[:nickname].downcase
					@current_brand.last_updated = DateTime.now
					@current_brand.save!(validate: false)
					flash[:info] = "You are now logged in!"
					redirect_to "/brands/dashboard"
				else
					flash[:error] = "That nickname has already been taken. Please choose another."
					redirect_to "/brands/enter-nickname"
				end
			else
				flash[:error] = "You must enter a valid nickname. Only lowercase letters, numbers, dashes, and underscores. Up to (and including) 45 characters."
				redirect_to "/brands/enter-nickname"
			end
		else
			flash[:notice] = "You must be logged in as a brand to perform that action."
			redirect_to "/brands/login"
		end
	end

	def sample_campaign
		@campaigns_else = Campaign.where(:status => "active").excludes(left: false, is_white_label: true).order_by([:date, :desc]).limit(4)
	end

	def destroy_tour_cookie
		if current_user
			unless cookies[:user_tour].nil? || cookies[:user_tour].to_s != "true"
				cookies.delete(:user_tour)
			end
		end
		redirect_to root_url
	end

	def create_tour_cookie
		if current_user
			if cookies[:user_tour].nil?
				cookies[:user_tour] = {:value => true, :expires => Time.now + 1.month}
			end
		end
		redirect_to root_url
	end

end
