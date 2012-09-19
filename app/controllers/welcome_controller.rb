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
	        #UserMailer.subscriber_confirmation(@subscriber).deliver
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
	        flash[:notice] = "Oops email is not valid."
	        respond_to do |format|
	          format.html #{ redirect_to(:action => 'index') }
	          format.js
	        end
	      end
	    end
  	end

  	def list
		@subscriber = Subscriber.all.order_by([:date, :desc])
	end

	def destroy
		@subscriber = Subscriber.find(params[:_id])
		@subscriber.destroy
		flash[:notice] = "Subscriber Destroyed"
		#redirect_to(:action => 'list')
		redirect_to(:controller=>"welcome", :action => 'list')
	end

end
