class WelcomeController < ApplicationController

	def index
		if current_user
			redirect_to '/dashboard'
		end
	end

	def new
		@subscriber = Subscriber.new
	end
  
	def share
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
	        UserMailer.subscriber_confirmation(@subscriber, root_url).deliver
	        Subscriber.increase_share(params[:link], params[:email])
	        flash[:notice] = "You're on the beta list!"
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

  	def invite
  		new_invite_code = Invitation.assign_invite_code()

  		@subscriber = Subscriber.find(params[:_id])
  		#@invite = Invitation.new(params[:invitation])
  		@invite = Invitation.new(:date => Time.now, :invite_code => new_invite_code, :email => @subscriber.email)
  		#@invite.invite_code = new_invite_code

  		if @invite.save
  			UserMailer.beta_invite(params[:email], @invite.invite_code, root_url).deliver
  			flash[:notice] = "Invitation sent"
  			redirect_to(:controller=>"welcome", :action => 'list')
  		else
  			flash[:notice] = "Uh oh... something went wrong"
  			redirect_to(:controller=>"welcome", :action => 'list')
  		end
  	end

  	def list
  		if current_user
	  		if current_user.account_type == "admin"
	  			@subscriber = Subscriber.all.order_by([:date, :desc])
	  			@invitation = Invitation.all.order_by([:date, :desc])
	  		else
	  			redirect_to root_url
	  		end
	  	else
	  		redirect_to root_url
	  	end

	end

	def destroy
		@subscriber = Subscriber.find(params[:_id])
		@subscriber.destroy
		flash[:notice] = "Subscriber Destroyed"
		#redirect_to(:action => 'list')
		redirect_to(:controller=>"welcome", :action => 'list')
	end

end
