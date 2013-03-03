class WelcomeController < ApplicationController

	def index
		if current_user
			redirect_to '/home'
		end
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
  		Subscriber.delay.consolidate()
  		flash[:notice] = 'Subscribers consolidated.'
  		redirect_to '/users/show'
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

end
